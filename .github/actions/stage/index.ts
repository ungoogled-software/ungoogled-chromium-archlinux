import * as artifactHost from '@actions/artifact';
import { ArtifactClient, DownloadResponse, UploadResponse } from '@actions/artifact';
import * as core from '@actions/core';
import * as exec from '@actions/exec';
import { ExecOptions } from '@actions/exec';
import * as github from '@actions/github';
import { readdirSync } from 'fs';

const shell = async (commandLine: string, args?: Array<string>, options?: ExecOptions): Promise<void> => {
    const code: number = await exec.exec(commandLine, args, options);

    if (code !== 0)
        throw new Error(`Stage: A ${commandLine} command errored with code ${code}`);
};

(async () => {
    const output = () => {
        console.log('Stage: Setting output', {
            'finished': input.finished,
            'chromium-version': input.chromiumVersion,
            'use-registry': input.useRegistry,
            'image-tag': input.imageTag
        });

        core.setOutput('finished', input.finished);
        core.setOutput('chromium-version', input.chromiumVersion);
        core.setOutput('use-registry', input.useRegistry);
        core.setOutput('image-tag', input.imageTag);
    };

    const artifact: ArtifactClient = artifactHost.create();
    const input = {
        finished: core.getInput('finished') === 'true',
        progressName: core.getInput('progress-name'),
        chromiumVersion: core.getInput('chromium-version', { required: true }),
        useRegistry: core.getInput('use-registry') === 'true',
        registryToken: core.getInput('registry-token'),
        imageTag: core.getInput('image-tag')
    };

    console.log('Stage: Got input', input);

    if (input.finished)
        return output();

    // Taken from https://github.com/easimon/maximize-build-space/blob/master/action.yml
    await core.group<void>('Stage: Free space on GitHub Runner...', async () => {
        await shell('sudo rm -rf /usr/share/dotnet');
        await shell('sudo rm -rf /usr/local/lib/android');
        await shell('sudo rm -rf /opt/ghc');
        await shell('sudo rm -rf /opt/hostedtoolcache/CodeQL');
        await shell('sudo docker image prune --all --force');
    });

    if (input.useRegistry) {
        await core.group<void>('Stage: Logging into docker registry...', () =>
            shell('docker', ['login', 'ghcr.io', '-u', github.context.actor, '-p', input.registryToken]));

        await core.group<void>('Stage: Pulling image from registry...', () =>
            shell('docker', ['pull', input.imageTag]));
    } else {
        await core.group<DownloadResponse>('Stage: Downloading image artifact...', () =>
            artifact.downloadArtifact('image'));

        await core.group<void>('Stage: Loading image from file...', () =>
            shell('docker load --input image'));

        await core.group<void>('Stage: Removing image file...', () =>
            shell('rm image'));
    }

    await core.group<void>('Stage: Creating input, output and progress directory...', () =>
        shell('mkdir input output progress'));

    if (input.progressName !== '') {
        await core.group<DownloadResponse>('Stage: Downloading progress artifact...', () =>
            artifact.downloadArtifact(input.progressName));

        await core.group<void>('Stage: Moving progress archive into input directory...', () =>
            shell('mv progress.tar.zst progress.tar.zst.sum input'));
    }

    const mount = (directory: string): Array<string> => ['--mount', `type=bind,source=${process.cwd()}/${directory},target=/mnt/${directory}`];

    await core.group<void>('Stage: Running docker container...', () =>
        shell('docker', ['run', '-e', 'TIMEOUT=330', ...mount('input'), ...mount('output'), ...mount('progress'), input.imageTag]));

    if (readdirSync('output').length !== 0) {
        console.log('Stage: Successfully built package');
        input.finished = true;
    }

    await core.group<UploadResponse>('Stage: Uploading progress...', () =>
        artifact.uploadArtifact(github.context.job, readdirSync('progress').map(node => `progress/${node}`), 'progress'));

    if (input.finished)
        await core.group<UploadResponse>('Stage: Uploading package...', () =>
            artifact.uploadArtifact(input.chromiumVersion, readdirSync('output').map(node => `output/${node}`), 'output'));

    output();
})().catch(core.setFailed);

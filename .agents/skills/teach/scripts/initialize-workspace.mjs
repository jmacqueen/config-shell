#!/usr/bin/env node

import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const target = process.argv[2];

if (!target) {
  console.error('Usage: node scripts/initialize-workspace.mjs <workspace-directory>');
  process.exit(1);
}

const workspace = resolve(target);
const directories = ['assets', 'learning-records', 'lessons', 'reference'];
const files = {
  'MISSION.md': '# Mission: {Topic}\n\n## Why\n\n## Success looks like\n\n## Constraints\n\n## Out of scope\n',
  'RESOURCES.md': '# {Topic} Resources\n\n## Knowledge\n\n## Wisdom (Communities)\n',
  'GLOSSARY.md': '# {Topic} Glossary\n\n## Terms\n',
  'NOTES.md': '# Notes\n',
};

mkdirSync(workspace, { recursive: true });

for (const directory of directories) {
  mkdirSync(resolve(workspace, directory), { recursive: true });
}

for (const [name, content] of Object.entries(files)) {
  const path = resolve(workspace, name);
  if (!existsSync(path)) {
    writeFileSync(path, content);
  }
}

console.log(`Teaching workspace initialized at ${workspace}`);

const fs = require('fs');
const path = require('path');

const rootEnvPath = path.join(__dirname, '..', '.env');
if (!fs.existsSync(rootEnvPath)) {
  console.log('No root .env found, skipping sync.');
  process.exit(0);
}

const envContent = fs.readFileSync(rootEnvPath, 'utf8');

const targets = [
  path.join(__dirname, '..', 'apps', 'backend', '.env'),
  path.join(__dirname, '..', 'apps', 'web', '.env.local'),
  path.join(__dirname, '..', 'apps', 'mobile', 'assets', '.env')
];

targets.forEach(target => {
  const targetDir = path.dirname(target);
  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
  }
  fs.writeFileSync(target, envContent, 'utf8');
  console.log(`Synced .env to ${target}`);
});

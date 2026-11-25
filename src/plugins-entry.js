import { SocialLogin } from '@capgo/capacitor-social-login';
import { BiometricAuth } from '@aparajita/capacitor-biometric-auth';
import { Filesystem, Directory, Encoding } from '@capacitor/filesystem';
import { Share } from '@capacitor/share';
import { App } from '@capacitor/app';
import { Capacitor, SystemBars } from '@capacitor/core';
import { CapacitorUpdater } from '@capgo/capacitor-updater';
window.CBN = { SocialLogin, BiometricAuth, Filesystem, Directory, Encoding, Share, App, Capacitor, SystemBars, Updater: CapacitorUpdater };

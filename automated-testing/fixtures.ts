import { test as base, type Page, type Locator } from '@playwright/test';
import { login } from './utils/common-functions';


export class LoggedInPage {
  // Page signed in as "admin".
  page: Page;

  constructor(page: Page) {
    this.page = page;
  }
}

// Declare the types of your fixtures.
export type MyFixtures = {
  loggedInPage: LoggedInPage;
};

export * from '@playwright/test';
import fs from 'fs';
import path from 'path';

export const test = base.extend<{}, MyFixtures>({
  loggedInPage: [async ({ browser }, use) => {
    const filePath = path.join(__dirname, process.env.AUTH_FILE_PATH || '');
    if (!filePath) {
      throw Error('File path is missing!');
    }
    let newPage: Page | undefined = undefined;

    const fileName = path.resolve(__dirname, filePath);
    const fileExists = fs.existsSync(fileName);

    if (!fileExists) {
      newPage = await browser.newPage({ storageState: undefined });
    } else {
      newPage = await browser.newPage({ storageState: fileName });
    }

    const loggedInPage = new LoggedInPage(newPage!);

    if (!fileExists) {
      loggedInPage.page = await login(newPage!);  
    }
    
    await use(loggedInPage);
    await browser.close();
  }, {scope: 'worker'} ]
});
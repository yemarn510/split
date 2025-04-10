import { expect, Page } from "@playwright/test";
import path from "path";


export async function addFriends(page: Page): Promise<void> {
  await page.getByRole('textbox', { name: 'Full Name, Nickname, etc.' }).click();
  await page.getByRole('textbox', { name: 'Full Name, Nickname, etc.' }).fill('YM');
  await page.getByRole('button', { name: 'Add Person' }).click();
  await page.getByRole('row', { name: 'minus-circle 2 delete' }).getByPlaceholder('Full Name, Nickname, etc.').click();
  await page.getByRole('row', { name: 'minus-circle 2 delete' }).getByPlaceholder('Full Name, Nickname, etc.').fill('NN');
  await page.getByRole('button', { name: 'Add Person' }).click();
  await page.getByRole('row', { name: 'minus-circle 3 delete' }).getByPlaceholder('Full Name, Nickname, etc.').click();
  await page.getByRole('row', { name: 'minus-circle 3 delete' }).getByPlaceholder('Full Name, Nickname, etc.').fill('Zwe');
  await page.getByRole('button', { name: 'Add Person' }).click();
  await page.getByRole('row', { name: 'minus-circle 4 delete' }).getByPlaceholder('Full Name, Nickname, etc.').click();
  await page.getByRole('row', { name: 'minus-circle 4 delete' }).getByPlaceholder('Full Name, Nickname, etc.').fill('MTE');
  await page.getByRole('button', { name: 'Add Person' }).click();
  await page.getByRole('row', { name: 'minus-circle 5 delete' }).getByPlaceholder('Full Name, Nickname, etc.').click();
  await page.getByRole('row', { name: 'minus-circle 5 delete' }).getByPlaceholder('Full Name, Nickname, etc.').fill('CC');
}

export async function login(page: Page): Promise<Page> {
  await page.goto('/');
  await page.locator('div').filter({ hasText: 'Login' }).nth(2).click();
  await page.getByRole('button', { name: 'google Login with Google' }).click();
  await page.getByRole('textbox', { name: 'Email or phone' }).click();
  await page.getByRole('textbox', { name: 'Email or phone' }).fill(process.env.GMAIL_USERNAME || '');
  await page.getByRole('button', { name: 'Next' }).click();
  await page.getByRole('textbox', { name: 'Enter your password' }).click();
  await page.getByRole('textbox', { name: 'Enter your password' }).fill(process.env.GMAIL_PASSWORD || '');
  await page.getByRole('button', { name: 'Next' }).click();
  await delay(300);
  await expect(page).toHaveURL('/');
  await expect(page.getByText('split my bills')).toBeVisible();
  await page.context().storageState({ path: path.join(__dirname, ('../' + process.env.AUTH_FILE_PATH) || '') });
  return page;
}

export const delay = ms => new Promise(resolve => setTimeout(resolve, ms))
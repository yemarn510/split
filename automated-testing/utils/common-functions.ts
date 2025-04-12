import { expect, Page } from "@playwright/test";
import path from "path";
import { friendPayload } from "../constants/friend-list.constants";


export async function deleteFriends(page: Page, maxNumber: number = 0): Promise<void> {
  const numberOffriends = maxNumber || 10;
  const friendArray = Array.from(Array(numberOffriends).keys());
  for (const aFriend of friendArray.reverse()) {
    const locator = await page.locator(`#person-row-${aFriend}`) || null;
    if(await locator.isVisible()) {
      await locator.getByRole('img', { name: 'delete' })?.locator('svg').click();
    }
  }
}

export async function addFriends(page: Page, maxNumber: number = 0): Promise<void> {
  for (let index = 0; index < friendPayload.length; index++) {
    if (maxNumber && index > maxNumber ) {
      return;
    }
    const friendName = friendPayload[index].name;
    await page.getByRole('button', { name: 'Add Person' }).click();
    await page.getByRole('row', { name: `minus-circle ${ index + 1 } delete` }).getByPlaceholder('Full Name, Nickname, etc.').click();
    await page.getByRole('row', { name: `minus-circle ${ index + 1 } delete` }).getByPlaceholder('Full Name, Nickname, etc.').fill(friendName);
  }
}

export async function selectFriends(page: Page, maxNumber: number = 0): Promise<void> {
  const numberOffriends = maxNumber || 10;
  const friendArray = Array.from(Array(numberOffriends).keys());
  for (const aFriend of friendArray) {
    const locator = await page.locator(`#person-row-${aFriend}`);
    if (await locator.isVisible()) {
      await locator.getByRole('cell', { name: 'minus-circle' }).click()
    }
  }
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
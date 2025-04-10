import { Page } from "@playwright/test";


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
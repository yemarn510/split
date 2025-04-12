import { MOCKED_CLIPBOARD_CONTENT_GENERAL, UN_EVENLY_DIVIDED } from '../constants/friend-list.constants';
import { test, expect } from '../fixtures';
import path from 'path';
import { addFriends, delay, deleteFriends, selectFriends } from '../utils/common-functions';

test.describe('without login', () => {
  test('has title', async ({ page }) => {
    await page.goto('/');
  
    // Expect a title "to contain" a substring.
    await expect(page).toHaveTitle('Split My Bill');
  });
});


test.describe('with login', () => {
  test('Evenly Divided Calculation Workflow', async ({ loggedInPage }) => {
    /* YM, NN, Zwe, MTE and CC goes for an evening dinner.
    Firstly they go to KFC, Mala Hotpot and Korean BBQ
    YM paid for KFC
    NN paid for Mala Hotpot
    Zwe paid for Korean BBQ
    MTE joined all
    CC didn't eat at all
    So he wasn't selected in the first step.
    */


    const page = loggedInPage.page;
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await delay(1000);
    await deleteFriends(page);
    await addFriends(page);
    await selectFriends(page, 4);

    await page.locator('div').filter({ hasText: /^Go Next$/ }).click();
    await page.getByRole('cell', { name: 'question' }).locator('div').nth(2).click();
    await expect(page.locator('div').filter({ hasText: /^YM$/ }).nth(1)).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^NN$/ }).nth(1)).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^Zwe$/ }).nth(1)).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^MTE$/ }).nth(1)).toBeVisible();
    await page.locator('.flex > .flex > .p-1').first().click();
    await page.getByRole('textbox', { name: 'KFC, McDonalds, etc.' }).click();
    await page.getByRole('textbox', { name: 'KFC, McDonalds, etc.' }).fill('KFC');
    await page.getByRole('textbox', { name: 'KFC, McDonalds, etc.' }).press('Tab');
    await page.getByPlaceholder('1').fill('1');
    await page.getByPlaceholder('0.00').click();
    await page.getByPlaceholder('0.00').fill('1250');
    await page.getByRole('table').getByRole('img', { name: 'check' }).locator('svg').click();
    await delay(500);

    await page.getByRole('button', { name: 'plus Add Item' }).click();
    await page.getByRole('row', { name: 'question 1 0 check close' }).getByPlaceholder('KFC, McDonalds, etc.').click();
    await page.getByRole('row', { name: 'question 1 0 check close' }).getByPlaceholder('KFC, McDonalds, etc.').fill('Mala Hotpot');
    await page.getByRole('row', { name: '2 question Mala Hotpot 1 0' }).getByPlaceholder('1').click();
    await page.getByRole('row', { name: '2 question Mala Hotpot 1 0' }).getByPlaceholder('1').fill('1');
    await page.getByRole('row', { name: '2 question Mala Hotpot 1 0' }).getByPlaceholder('1').press('Tab');
    await page.getByRole('row', { name: '2 question Mala Hotpot 1 0' }).getByPlaceholder('0.00').fill('370');
    await page.getByRole('cell', { name: 'question' }).locator('div').nth(1).click();
    await page.getByRole('dialog', { name: 'Set Paid By' }).getByRole('img').nth(2).click();
    await page.getByRole('table').getByRole('img', { name: 'check' }).locator('svg').click();
    await delay(500);

    await page.getByRole('button', { name: 'plus Add Item' }).click();
    await page.getByRole('row', { name: 'question 1 0 check close' }).getByPlaceholder('KFC, McDonalds, etc.').click();
    await page.getByRole('row', { name: 'question 1 0 check close' }).getByPlaceholder('KFC, McDonalds, etc.').fill('Korean BBQ');
    await page.getByRole('row', { name: '3 question Korean BBQ 1 0' }).getByPlaceholder('1').click();
    await page.getByRole('row', { name: '3 question Korean BBQ 1 0' }).getByPlaceholder('1').fill('4');
    await page.getByRole('row', { name: '3 question Korean BBQ 1 0' }).getByPlaceholder('1').press('Tab');
    await page.getByRole('row', { name: '3 question Korean BBQ 4 0' }).getByPlaceholder('0.00').fill('980');
    await page.getByRole('cell', { name: 'question' }).locator('div').nth(2).click();
    await page.getByRole('dialog', { name: 'Set Paid By' }).getByRole('img').nth(3).click();
    await page.getByRole('table').getByRole('img', { name: 'check' }).locator('svg').click();
    await delay(500);

    await page.locator('div').filter({ hasText: /^Go Next$/ }).click();

    await page.locator('.w-full > .bg-third').first().click();
    await page.locator('.flex > .relative > div:nth-child(2)').first().click();
    await page.getByRole('dialog', { name: 'Choose Participants' }).locator('img').nth(1).click();
    await page.locator('div:nth-child(3) > .relative > div:nth-child(2)').click();
    await page.getByRole('dialog', { name: 'Choose Participants' }).locator('img').nth(3).click();
    await page.getByRole('button', { name: 'Close' }).click();
    await page.locator('div').filter({ hasText: /^Paid ByNNMala Hotpot \/ 370Select ParticipantsSelect All$/ }).locator('svg').first().click();
    await page.getByRole('dialog', { name: 'Choose Participants' }).locator('img').first().click();
    await page.getByRole('dialog', { name: 'Choose Participants' }).locator('img').nth(1).click();
    await page.locator('div:nth-child(3) > .relative > div:nth-child(2)').click();
    await page.getByRole('dialog', { name: 'Choose Participants' }).locator('img').nth(3).click();
    await page.getByRole('button', { name: 'Close' }).click();
    await page.locator('.w-full > .bg-third').first().click();
    await page.getByRole('dialog', { name: 'Choose Participants' }).locator('img').first().click();
    await page.locator('div:nth-child(2) > .relative > div:nth-child(2)').click();
    await page.getByRole('dialog', { name: 'Choose Participants' }).locator('img').nth(2).click();
    await page.getByRole('dialog', { name: 'Choose Participants' }).locator('img').nth(3).click();
    await page.getByRole('button', { name: 'Close' }).click();
    await page.locator('div').filter({ hasText: /^Go Next$/ }).click();

    await expect(page.getByText('650.00').first()).toBeVisible();
    await expect(page.getByText('650.00').nth(1)).toBeVisible();
    await expect(page.getByText('650.00').nth(2)).toBeVisible();
    await expect(page.getByText('650.00').nth(3)).toBeVisible();
    await expect(page.getByText('650.00').nth(4)).not.toBeVisible();

    await page.locator('div').filter({ hasText: /^Share$/ }).click();
    // for YM
    await expect(page.getByLabel('Share with your friends').getByText('312.50').first()).toBeVisible();
    await expect(page.getByLabel('Share with your friends').getByText('92.50').first()).toBeVisible();
    await expect(page.getByLabel('Share with your friends').getByText('245.00').first()).toBeVisible();
    // for NN
    await expect(page.getByLabel('Share with your friends').getByText('312.50').nth(1)).toBeVisible();
    await expect(page.getByLabel('Share with your friends').getByText('92.50').nth(1)).toBeVisible();
    await expect(page.getByLabel('Share with your friends').getByText('245.00').nth(1)).toBeVisible();
    // for Zwe
    await expect(page.getByLabel('Share with your friends').getByText('312.50').nth(2)).toBeVisible();
    await expect(page.getByLabel('Share with your friends').getByText('92.50').nth(2)).toBeVisible();
    await expect(page.getByLabel('Share with your friends').getByText('245.00').nth(2)).toBeVisible();
    // for MTE
    await expect(page.getByLabel('Share with your friends').getByText('312.50').nth(3)).toBeVisible();
    await expect(page.getByLabel('Share with your friends').getByText('92.50').nth(3)).toBeVisible();
    await expect(page.getByLabel('Share with your friends').getByText('245.00').nth(3)).toBeVisible();
    // for CC (should not show in UI)
    await expect(page.getByLabel('Share with your friends').getByText('312.50').nth(4)).not.toBeVisible();
    await expect(page.getByLabel('Share with your friends').getByText('92.50').nth(4)).not.toBeVisible();
    await expect(page.getByLabel('Share with your friends').getByText('245.00').nth(4)).not.toBeVisible();

    await page.getByRole('button', { name: 'copy Copy To Clipboard' }).click();

    const clipboardContent = await page.evaluate(() => navigator.clipboard.readText());
    await expect(clipboardContent).toBe(MOCKED_CLIPBOARD_CONTENT_GENERAL);
  });

  test('Unevenly Divided Calculation Workflow', async ({ loggedInPage }) => {
    /*
    kfc 370, coffee 150, after u 750, snack 540
    */
    const page = loggedInPage.page;

    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await delay(1000);
    await deleteFriends(page);
    await addFriends(page);
    await selectFriends(page);

    await page.getByText('Go Next').click();
    await page.getByRole('cell', { name: 'question' }).locator('div').nth(2).click();
    await expect(page.locator('div').filter({ hasText: /^YM$/ }).nth(1)).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^NN$/ }).nth(1)).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^Zwe$/ }).nth(1)).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^MTE$/ }).nth(1)).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^CC$/ }).nth(1)).toBeVisible();
    await page.locator('div').filter({ hasText: /^YM$/ }).nth(1).click();
    await page.getByRole('textbox', { name: 'KFC, McDonalds, etc.' }).click();
    await page.getByRole('textbox', { name: 'KFC, McDonalds, etc.' }).fill('KFC');
    await page.getByPlaceholder('0.00').click();
    await page.getByPlaceholder('0.00').fill('370');
    await page.getByRole('table').getByRole('img', { name: 'check' }).locator('svg').click();
    await delay(300);

    await page.getByRole('button', { name: 'plus Add Item' }).click();
    await page.getByRole('row', { name: 'question 1 0 check close' }).getByPlaceholder('KFC, McDonalds, etc.').fill('Coffee');
    await page.getByRole('row', { name: 'question Coffee 1 0 check close' }).getByPlaceholder('1').click();
    await page.getByRole('cell', { name: 'question' }).locator('div').nth(2).click();
    await page.locator('div').filter({ hasText: /^CC$/ }).nth(1).click();
    await page.getByRole('row', { name: 'CC Coffee 1 0 check close' }).getByPlaceholder('0.00').click();
    await page.getByRole('row', { name: 'CC Coffee 1 0 check close' }).getByPlaceholder('0.00').fill('150');
    await page.getByRole('button', { name: 'plus Add Item' }).click();
    await page.getByRole('row', { name: 'question 1 0 check close' }).getByPlaceholder('KFC, McDonalds, etc.').click();
    await page.getByRole('row', { name: 'question 1 0 check close' }).getByPlaceholder('KFC, McDonalds, etc.').fill('After you');
    await page.getByRole('cell', { name: 'question' }).locator('div').nth(2).click();
    await page.locator('div').filter({ hasText: /^MTE$/ }).nth(1).click();
    await page.getByRole('row', { name: 'MTE After you 1 0 check close' }).getByPlaceholder('0.00').click();
    await page.getByRole('row', { name: 'MTE After you 1 0 check close' }).getByPlaceholder('0.00').fill('750');
    await page.getByRole('table').getByRole('img', { name: 'check' }).locator('svg').click();
    await delay(300);

    await page.getByRole('button', { name: 'plus Add Item' }).click();
    await page.getByRole('row', { name: 'question 1 0 check close' }).getByPlaceholder('KFC, McDonalds, etc.').click();
    await page.getByRole('row', { name: 'question 1 0 check close' }).getByPlaceholder('KFC, McDonalds, etc.').fill('Snacks');
    await page.getByRole('row', { name: 'question Snacks 1 0 check close' }).getByPlaceholder('0.00').click();
    await page.getByRole('row', { name: 'question Snacks 1 0 check close' }).getByPlaceholder('0.00').fill('540');
    await page.getByRole('cell', { name: 'question' }).locator('div').nth(2).click();
    await page.getByRole('dialog', { name: 'Set Paid By' }).locator('img').nth(2).click();
    await page.getByRole('table').getByRole('img', { name: 'check' }).locator('svg').click();
    await delay(300);

    // step 3
    await page.getByText('Go Next').click();
    await page.locator('.w-full > .bg-third').first().click();
    await page.getByRole('button', { name: 'Select All', exact: true }).click();
    await page.getByRole('button', { name: 'Close' }).click();
    await expect(page.locator('div').filter({ hasText: /^\+2$/ })).toBeVisible();


    await page.getByRole('button', { name: 'user-add Select Participants' }).nth(1).click();
    await page.locator('.flex > .relative > div:nth-child(2)').first().click();
    await page.getByRole('dialog', { name: 'Choose Participants' }).locator('img').nth(4).click();
    await page.getByRole('button', { name: 'Close' }).click();
    await page.getByRole('button', { name: 'user-add Select Participants' }).nth(2).click();
    await page.locator('div').filter({ hasText: /^NN$/ }).nth(2).click();
    await page.locator('div:nth-child(3) > .relative > div:nth-child(2)').click();
    await page.locator('div:nth-child(4) > .relative > div:nth-child(2)').click();
    await page.getByRole('button', { name: 'Close' }).click();
    await page.getByRole('button', { name: 'user-add Select Participants' }).nth(3).click();
    await page.getByRole('dialog', { name: 'Choose Participants' }).locator('img').nth(1).click();
    await page.getByRole('dialog', { name: 'Choose Participants' }).locator('img').nth(2).click();
    await page.getByRole('dialog', { name: 'Choose Participants' }).locator('img').nth(3).click();
    await page.getByRole('button', { name: 'Close' }).click();

    // step 4
    await page.getByText('Go Next').click();
    await expect(page.getByRole('button', { name: 'caret-right YM' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'caret-right NN' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'caret-right Zwe' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'caret-right MTE' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'caret-right CC' })).toBeVisible();
    await expect(page.getByText('149.00').first()).toBeVisible();
    await expect(page.getByText('504.00').first()).toBeVisible();
    await expect(page.getByText('504.00').nth(1)).toBeVisible();
    await expect(page.getByText('504.00').nth(2)).toBeVisible();
    await expect(page.getByText('149.00').nth(1)).toBeVisible();
    await page.locator('div').filter({ hasText: /^Share$/ }).click();
    await page.getByRole('button', { name: 'copy Copy To Clipboard' }).click();

    const clipboardContent = await page.evaluate(() => navigator.clipboard.readText());
    await expect(clipboardContent).toBe(UN_EVENLY_DIVIDED);
  });

  

  test('should work with receipt image upload', async ({ loggedInPage }) => {
    let page = loggedInPage.page;

    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await delay(1000);
    await deleteFriends(page);
    await addFriends(page);
    await selectFriends(page);

    await page.getByText('Go Next').click();

    await page.getByRole('button', { name: 'camera' }).click();
    await page.getByRole('button', { name: 'user Choose Paid By' }).click();
    await page.locator('.max-w-\\[200px\\] > div > .flex > .p-1').first().click();

    const uploadButtonLocator = page.getByRole('button', { name: 'inbox Click to upload' });
    const fileName = 'receipt.jpeg';
    const fileDirectory = '../test-files/receipt.jpeg';

    const fileChooserPromise = page.waitForEvent('filechooser');
    await uploadButtonLocator.click();
    const fileChooser = await fileChooserPromise;
    if (!fileDirectory) {
      throw Error('File Path is not available');
    }
    
    await fileChooser.setFiles(path.join(__dirname, fileDirectory));
    await page.waitForResponse(`https://xw3pr7ak-7dqrsyftta-de.a.run.app/extract_data?output_language=English`);
    await page.waitForLoadState('networkidle');
    await expect(page.getByText(fileName)).toBeVisible();

    await page.getByRole('button', { name: 'See the result' }).click();
    
    await expect(page.getByRole('cell', { name: '313.00' })).toBeVisible();
    
    await page.getByRole('row', { name: '1 YM Boba Strawberry 1 72' }).locator('svg').first().click();
    await expect(page.getByRole('cell', { name: 'Boba Strawberry' }).getByPlaceholder('KFC, McDonalds, etc.')).toBeVisible();
    await expect(page.getByRole('row', { name: '1 YM Boba Strawberry 1 72' }).getByPlaceholder('1')).toBeVisible();
    await expect(page.getByRole('row', { name: '1 YM Boba Strawberry 1 72' }).getByPlaceholder('0.00')).toBeVisible();
    await expect(page.getByLabel('Upload your receipt').getByRole('img', { name: 'check' }).locator('svg')).toBeVisible();
    await page.getByLabel('Upload your receipt').getByRole('img', { name: 'check' }).locator('svg').click();

    await page.getByRole('row', { name: 'YM Boba Blueberry 1 72 edit delete' }).locator('svg').first().click();
    await expect(page.getByRole('cell', { name: 'Boba Blueberry' }).getByPlaceholder('KFC, McDonalds, etc.')).toBeVisible();
    await expect(page.getByRole('row', { name: '2 YM Boba Blueberry 1 72' }).getByPlaceholder('1')).toBeVisible();
    await expect(page.getByRole('row', { name: '2 YM Boba Blueberry 1 72' }).getByPlaceholder('0.00')).toBeVisible();
    await expect(page.getByLabel('Upload your receipt').getByRole('img', { name: 'check' }).locator('svg')).toBeVisible();
    await page.getByLabel('Upload your receipt').getByRole('img', { name: 'check' }).locator('svg').click();
    
    await page.getByRole('row', { name: '3 YM Korean Strawberry 1 169' }).locator('svg').first().click();
    await expect(page.getByRole('cell', { name: 'Korean Strawberry' }).getByPlaceholder('KFC, McDonalds, etc.')).toBeVisible();
    await expect(page.getByRole('row', { name: '3 YM Korean Strawberry 1 169' }).getByPlaceholder('1')).toBeVisible();
    await expect(page.getByRole('cell', { name: '169' }).getByPlaceholder('0.00')).toBeVisible();
    await page.getByLabel('Upload your receipt').getByRole('img', { name: 'check' }).locator('svg').click();

    await expect(page.getByRole('button', { name: 'Save Items' })).toBeVisible();
    await page.getByRole('button', { name: 'Save Items' }).click();

    await delay(1000);

    await page.getByRole('row', { name: '1 YM Boba Strawberry 1 72' }).locator('svg').first().click();
    await expect(page.getByRole('cell', { name: 'Boba Strawberry' }).getByPlaceholder('KFC, McDonalds, etc.')).toBeVisible();
    await expect(page.getByRole('row', { name: '1 YM Boba Strawberry 1 72' }).getByPlaceholder('1')).toBeVisible();
    await expect(page.getByRole('row', { name: '1 YM Boba Strawberry 1 72' }).getByPlaceholder('0.00')).toBeVisible();
    await expect(page.getByRole('table').getByRole('img', { name: 'check' }).locator('svg')).toBeVisible();

    await page.getByRole('table').getByRole('img', { name: 'check' }).locator('svg').click();
    await page.getByRole('row', { name: 'YM Boba Blueberry 1 72 edit delete' }).locator('svg').first().click();
    await expect(page.getByRole('cell', { name: 'Boba Blueberry' }).getByPlaceholder('KFC, McDonalds, etc.')).toBeVisible();
    await expect(page.getByRole('row', { name: '2 YM Boba Blueberry 1 72' }).getByPlaceholder('1')).toBeVisible();
    await expect(page.getByRole('row', { name: '2 YM Boba Blueberry 1 72' }).getByPlaceholder('0.00')).toBeVisible();
    await expect(page.getByRole('table').getByRole('img', { name: 'check' }).locator('svg')).toBeVisible();

    await page.getByRole('table').getByRole('img', { name: 'check' }).locator('svg').click();
    await page.getByRole('row', { name: '3 YM Korean Strawberry 1 169' }).locator('svg').first().click();
    await expect(page.getByRole('cell', { name: 'Korean Strawberry' }).getByPlaceholder('KFC, McDonalds, etc.')).toBeVisible();
    await expect(page.getByRole('row', { name: '3 YM Korean Strawberry 1 169' }).getByPlaceholder('1')).toBeVisible();
    await expect(page.getByRole('cell', { name: '169' }).getByPlaceholder('0.00')).toBeVisible();
    await expect(page.getByRole('table').getByRole('img', { name: 'check' }).locator('svg')).toBeVisible();

    await page.getByRole('table').getByRole('img', { name: 'check' }).locator('svg').click();
    await page.getByText('Go Next').click();
  });
})

import { expect } from '@playwright/test';
import { addFriends, delay, deleteFriends, selectFriends } from '../utils/common-functions';
import { test } from '../fixtures';
import { API_ENDPOINT, friendPayload } from '../constants/friend-list.constants';

test.describe('Testing First Step Without Login', () => {

  test.beforeEach(async ({ page }) => {
    // Go to the starting url before each test.
    await page.goto('/');
  });

  test('should show the error message when friend is not selected', async ({ page }) => {
    await page.locator('div').filter({ hasText: /^Go Next$/ }).click();
    await page.getByText('Please select at least one').isVisible();
    await page.getByRole('button', { name: 'plus Add Item' }).isHidden()
  });

  test('Should be able to add friends', async ({page}) => {
    await expect(page.locator('#person-row-0')).toBeVisible();
    await addFriends(page, 3);
    await expect(page.locator('#person-row-3')).toBeVisible();
  });

  test('delete button should work', async ({page}) => {
    await expect(page.locator('#person-row-0')).toBeVisible();
    await addFriends(page, 3);
    await page.locator('#person-row-4').getByRole('img', { name: 'delete' }).locator('svg').click();
    await expect(page.locator('#person-row-4')).not.toBeVisible();
  });

  test('Only selected friends should be visible in the next step', async ({ page }) => {
    await addFriends(page);
    await page.locator('#person-row-0').getByRole('cell', { name: 'minus-circle' }).click();
    await page.locator('#person-row-1').getByRole('cell', { name: 'minus-circle' }).click();
    await page.locator('#person-row-2').getByRole('cell', { name: 'minus-circle' }).click();
    await page.locator('#person-row-3').getByRole('cell', { name: 'minus-circle' }).click();

    await page.locator('div').filter({ hasText: /^Go Next$/ }).locator('div').click();
    await page.getByRole('cell', { name: 'question' }).locator('div').nth(2).click();
  
    await expect(page.locator('div').filter({ hasText: /^YM$/ }).nth(1)).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^NN$/ }).nth(1)).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^Zwe$/ }).nth(1)).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^MTE$/ }).nth(1)).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^CC$/ }).nth(1)).not.toBeVisible(); // this guys was not selected
  });

  test('should go to step 2 if a friend is selected', async ({ page }) => {
    await page.locator('#person-row-0').getByRole('cell', { name: 'minus-circle' }).click();
    await page.locator('div').filter({ hasText: /^Go Next$/ }).click();
    await page.getByText('Please select at least one').isHidden();
    await page.getByRole('button', { name: 'plus Add Item' }).isVisible();
  });
});

test.describe('Testing First Step After Logged In', () => {
  test('login should be fine', async ({ loggedInPage }) => {
    const page = loggedInPage.page;
    await page.goto('/');
    await expect(page.getByText('split my bills')).toBeVisible();
  });

  test('Adding friend should be fine with API call', async ({ loggedInPage }) => {
    const page = loggedInPage.page;

    await page.goto('/');
    await delay(500);
    await deleteFriends(page);
    await addFriends(page);
    await selectFriends(page);
    await page.getByRole('checkbox', { name: 'Save This List' }).check();
    await page.getByText('Go Next').click();
    const request = await page.waitForRequest(request => 
      request.url().includes(`${API_ENDPOINT.friends}`) && request.method() === 'POST'
    );
    const response = await page.waitForResponse(`${API_ENDPOINT.friends}`);
    expect(response.ok()).toBeTruthy();
    
    const postData: { name: string, profile: string}[] = request.postDataJSON(); // get parsed JSON body
    
    expect(postData.flatMap(each => each.name)).toEqual(friendPayload.flatMap(each => each.name));
  });
});


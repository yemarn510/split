import { test, expect } from '../fixtures';


import { addFriends, delay, deleteFriends, selectFriends } from '../utils/common-functions';

test.describe('without login', () => {
  test('has title', async ({ page }) => {
    await page.goto('/');
  
    // Expect a title "to contain" a substring.
    await expect(page).toHaveTitle('Split My Bill');
  });
});


test.describe('with login', () => {
  test('normal workflow', async ({ loggedInPage }) => {
    const page = loggedInPage.page;
    await page.goto('/');
    await delay(1000);
    await deleteFriends(page);
    await addFriends(page);
    await selectFriends(page);
  });
})

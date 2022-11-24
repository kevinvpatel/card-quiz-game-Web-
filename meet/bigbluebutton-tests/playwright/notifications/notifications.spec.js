const { test } = require('@playwright/test');
const { Notifications } = require('./notifications');
const { ChatNotifications } = require('./chatNotifications');
const { PresenterNotifications } = require('./presenterNotifications');

test.describe.parallel('Notifications', () => {
  test('Save settings notification @ci', async ({ browser, context, page }) => {
    const notifications = new Notifications(browser, context);
    await notifications.initModPage(page);
    await notifications.saveSettingsNotification();
  });

  test('Audio notifications @ci', async ({ browser, context, page }) => {
    const notifications = new Notifications(browser, context);
    await notifications.initModPage(page);
    await notifications.audioNotification();
  });

  test('User join notification', async ({ browser, context, page }) => {
    const notifications = new Notifications(browser, context);
    await notifications.initModPage(page);
    await notifications.getUserJoinPopupResponse();
  });

  test('Raise and lower hand notification @ci', async ({ browser, context, page }) => {
    const notifications = new Notifications(browser, context);
    await notifications.initModPage(page);
    await notifications.raiseAndLowerHandNotification();
  });

  test.describe.parallel('Chat', () => {
    test('Public Chat notification', async ({ browser, context, page }) => {
      const chatNotifications = new ChatNotifications(browser, context);
      await chatNotifications.initPages(page, true);
      await chatNotifications.publicChatNotification();
    });

    test('Private Chat notification', async ({ browser, context, page }) => {
      const chatNotifications = new ChatNotifications(browser, context);
      await chatNotifications.initPages(page, true);
      await chatNotifications.privateChatNotification();
    });
  });

  test.describe.parallel('Presenter @ci', () => {
    test('Poll results notification', async ({ browser, context, page }) => {
      test.fixme(true, 'Different behaviors in the development and production environment');
      const presenterNotifications = new PresenterNotifications(browser, context);
      await presenterNotifications.initModPage(page);
      await presenterNotifications.publishPollResults();
    });

    test('Presentation upload notification', async ({ browser, context, page }) => {
      const presenterNotifications = new PresenterNotifications(browser, context);
      await presenterNotifications.initPages(page, true);
      await presenterNotifications.fileUploaderNotification();
    });

    test('Screenshare notification', async ({ browser, context, page }) => {
      const presenterNotifications = new PresenterNotifications(browser, context);
      await presenterNotifications.initModPage(page);
      await presenterNotifications.screenshareToast();
    });
  });
});

/**
 * @param {import("../world")} world
 * @returns {{
 *   getMemberWalletBalances(currencies?: string[]): Promise<any>,
 *   getMemberWalletBalance(currency?: string): Promise<number>,
 *   requestPayment(payload?: object): Promise<any>,
 *   notifyPaymentFailed(payload?: object): Promise<any>,
 *   settleWager(payload?: object): Promise<any>,
 *   cancelWager(payload?: object): Promise<any>,
 *   resettleWager(payload?: object): Promise<any>,
 *   requestTransferIn(payload?: object): Promise<any>,
 *   requestTransferOut(payload?: object): Promise<any>,
 *   undoWager(payload?: object): Promise<any>,
 *   notifyWagerUpdate(payload?: object): Promise<any>,
 *   requestCancelTransfer(payload?: object): Promise<any>,
 * }}
 */
function createWalletContext(world) {
  // AMO001 - Get Member Wallet Balance
  async function getMemberWalletBalances(currencies = [world.vars.currency]) {
    return world.request(
      "GET",
      world.config.merchant_settings.get_payment_api,
      {
        platform_username: world.vars.platform_username,
        currencies,
      },
    );
  }

  // AMO001 - Get one specific member wallet balance
  async function getMemberWalletBalance(currency = world.vars.currency) {
    const response = await getMemberWalletBalances([currency]);
    const data = world.responseData(response);

    return Number(data?.balances?.[currency] ?? 0);
  }

  // AMO003 - Request Payment
  function requestPayment(payload = {}) {
    return world.request(
      "POST",
      world.config.merchant_settings.request_payment_api,
      payload,
    );
  }

  // AMO004 - Notify Payment Failed
  function notifyPaymentFailed(payload = {}) {
    return world.request(
      "POST",
      world.config.merchant_settings.notify_payment_failed_api,
      payload,
    );
  }

  // AMO007 - Settle Wager
  function settleWager(payload = {}) {
    return world.request(
      "POST",
      world.config.merchant_settings.settle_order_api,
      payload,
    );
  }

  // AMO008 - Cancel Wager
  function cancelWager(payload = {}) {
    return world.request(
      "POST",
      world.config.merchant_settings.cancel_order_api,
      payload,
    );
  }

  // AMO009 - Resettle Wager
  function resettleWager(payload = {}) {
    return world.request(
      "POST",
      world.config.merchant_settings.resettle_wager_api,
      payload,
    );
  }

  // AMO010 - Request Transfer In
  function requestTransferIn(payload = {}) {
    return world.request(
      "POST",
      world.config.merchant_settings.deposit_payment_api,
      payload,
    );
  }

  // AMO011 - Request Transfer Out
  function requestTransferOut(payload = {}) {
    return world.request(
      "POST",
      world.config.merchant_settings.withdraw_payment_api,
      payload,
    );
  }

  // AMO012 - Undo Wager
  function undoWager(payload = {}) {
    return world.request(
      "POST",
      world.config.merchant_settings.undo_wager_api,
      payload,
    );
  }

  // AMO013 - Notify Wager Update
  function notifyWagerUpdate(payload = {}) {
    return world.request(
      "POST",
      world.config.merchant_settings.notify_wager_api,
      payload,
    );
  }

  // AMO014 - Request Cancel Transfer
  function requestCancelTransfer(payload = {}) {
    return world.request(
      "POST",
      world.config.merchant_settings.cancel_transfer_api,
      payload,
    );
  }

  return {
    getMemberWalletBalances,
    getMemberWalletBalance,
    requestPayment,
    notifyPaymentFailed,
    settleWager,
    cancelWager,
    resettleWager,
    requestTransferIn,
    requestTransferOut,
    undoWager,
    notifyWagerUpdate,
    requestCancelTransfer,
  };
}

module.exports = createWalletContext;

alias StoneBank.Accounts.TransactionNotificators
alias StoneBank.Accounts.TransactionFactories
alias StoneBank.Accounts.TransactionProcessors

Mox.defmock(StoneBank.TimeMock, for: StoneBank.Time)
Mox.defmock(StoneBank.AccountsMock, for: StoneBank.Accounts)
Mox.defmock(StoneBank.Accounts.AccountCallbacksMock, for: StoneBank.Accounts.AccountCallbacks)
Mox.defmock(TransactionProcessors.GiftProcessorMock, for: TransactionProcessors.Behaviour)
Mox.defmock(TransactionProcessors.WithdrawalProcessorMock, for: TransactionProcessors.Behaviour)
Mox.defmock(TransactionProcessors.TransferenceProcessorMock, for: TransactionProcessors.Behaviour)
Mox.defmock(TransactionNotificators.NotificatorMock, for: TransactionNotificators.Behaviour)
Mox.defmock(TransactionFactories.GiftFactoryMock, for: TransactionFactories.GiftFactory)
Mox.defmock(TransactionNotificators.GiftNotificatorMock, for: TransactionNotificators.Behaviour)

Mox.defmock(TransactionFactories.TransferenceFactoryMock,
  for: TransactionFactories.TransferenceFactory
)

Mox.defmock(TransactionFactories.WithdrawalFactoryMock,
  for: TransactionFactories.WithdrawalFactory
)

Mox.defmock(TransactionNotificators.WithdrawalNotificatorMock,
  for: TransactionNotificators.Behaviour
)

Mox.defmock(TransactionNotificators.TransferenceNotificatorMock,
  for: TransactionNotificators.Behaviour
)

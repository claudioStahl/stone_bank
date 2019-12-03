Mox.defmock(StoneBank.TimeMock, for: StoneBank.Time)
Mox.defmock(StoneBank.AccountsMock, for: StoneBank.Accounts)

Mox.defmock(StoneBank.Accounts.TransactionFactories.GiftFactoryMock,
  for: StoneBank.Accounts.TransactionFactories.GiftFactory
)

Mox.defmock(StoneBank.Accounts.TransactionFactories.TransferenceFactoryMock,
  for: StoneBank.Accounts.TransactionFactories.TransferenceFactory
)

Mox.defmock(StoneBank.Accounts.TransactionFactories.WithdrawalFactoryMock,
  for: StoneBank.Accounts.TransactionFactories.WithdrawalFactory
)

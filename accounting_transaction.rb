require 'date'
require 'active_support/core_ext/enumerable'

class ImmutableTransactionError < StandardError; end
class UnableToPost < StandardError; end

class Entry
  attr_accessor :amount, :date, :account, :inventory_transaction

  def initialize(amount, date, account, inventory_transaction)
    @amount = amount
    @date = date
    @account = account
    @inventory_transaction = inventory_transaction
  end

  def post!
    account.entries << self
  end
end

class Account
  attr_accessor :name, :entries

  def initialize(name)
    @name = name
    @entries = [] 
  end

  def withdraw(quantity, target_account, date)
    trans = InventoryTransaction.new(date)
    trans.add(-quantity, self)
    trans.add(quantity, target_account)
    trans.post!
  end

  def balance
    entries.sum(&:amount)
  end

end

class InventoryTransaction
  attr_accessor :date, :entries

  def initialize(date = Date.today)
    @posted = false
    @entries = []
    @date = date
  end

  def posted?
    !!@posted 
  end

  def add(amount, account)
    raise ImmutableTransactionError, "cannot add entry to a transaction that's already been posted" if posted?
    entries << Entry.new(amount, date, account, self)
  end

  def may_post?
    balance == 0
  end

  def balance 
    entries.sum(&:amount)
  end

  def post!
    raise UnableToPost unless may_post?
    entries.each(&:post!)
    @posted = true
  end

end

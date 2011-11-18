$: << "."
require 'accounting_transaction'

describe InventoryTransaction do

  it "should post the right balances" do
    receivables = Account.new "receivables"
    deferred = Account.new "deferred"
    revenue = Account.new "revenue"

    multi = InventoryTransaction.new
    multi.add -700, revenue
    multi.add 500, receivables
    multi.add 200, deferred
    multi.post!

    receivables.balance.should == 500
    deferred.balance.should == 200
    revenue.balance.should == -700
  end

  it "should not let you post if the totals don't balance" do
    receivables = Account.new "receivables"
    revenue = Account.new "revenue"

    txn = InventoryTransaction.new
    txn.add -700, revenue
    txn.add 500, receivables
    txn.balance.should == -200
    expect { txn.post! }.should raise_error(UnableToPost)
  end

  describe "withdrawing amounts" do
  end


end

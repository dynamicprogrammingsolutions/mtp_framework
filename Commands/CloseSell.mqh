class CCloseSell : public COrderCommand
{
public:
   CCloseSell()
   {
      trade_direction = tdShort;
      transaction_type = ttClose;
   }
   CCloseSell(bool _delete_after_use)
   {
      delete_after_use = _delete_after_use;
      trade_direction = tdShort;
      transaction_type = ttClose;
   }
};
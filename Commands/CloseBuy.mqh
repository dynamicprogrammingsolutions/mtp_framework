class CCloseBuy : public COrderCommand
{
public:
   CCloseBuy()
   {
      trade_direction = tdLong;
      transaction_type = ttClose;
   }
   CCloseBuy(bool _delete_after_use)
   {
      delete_after_use = _delete_after_use;
      trade_direction = tdLong;
      transaction_type = ttClose;
   }
};
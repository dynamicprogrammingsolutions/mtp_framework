class COpenBuy : public COrderCommand
{
public:
   COpenBuy()
   {
      trade_direction = tdLong;
      transaction_type = ttOpen;
   }
   COpenBuy(bool _delete_after_use)
   {
      delete_after_use = _delete_after_use;
      trade_direction = tdLong;
      transaction_type = ttOpen;
   }
};
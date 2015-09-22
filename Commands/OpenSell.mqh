class COpenSell : public COrderCommand
{
public:
   COpenSell()
   {
      trade_direction = tdShort;
      transaction_type = ttOpen;
   }
   COpenSell(bool _delete_after_use)
   {
      delete_after_use = _delete_after_use;
      trade_direction = tdShort;
      transaction_type = ttOpen;
   }
};
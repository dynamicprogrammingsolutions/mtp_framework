class CCloseAll : public COrderCommand
{
public:
   CCloseAll()
   {
      trade_direction = tdNone;
      transaction_type = ttClose;
   }
   CCloseAll(bool _delete_after_use)
   {
      delete_after_use = _delete_after_use;
      trade_direction = tdNone;
      transaction_type = ttClose;
   }
};
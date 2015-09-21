class CCloseAll : public COrderCommand
{
public:
   CCloseAll()
   {
      trade_direction = tdNone;
      transaction_type = ttClose;
   }
};
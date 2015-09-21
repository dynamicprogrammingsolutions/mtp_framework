class CCloseBuy : public COrderCommand
{
public:
   CCloseBuy()
   {
      trade_direction = tdLong;
      transaction_type = ttClose;
   }
};
class COpenBuy : public COrderCommand
{
public:
   COpenBuy()
   {
      trade_direction = tdLong;
      transaction_type = ttOpen;
   }
};
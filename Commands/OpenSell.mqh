class COpenSell : public COrderCommand
{
public:
   COpenSell()
   {
      trade_direction = tdShort;
      transaction_type = ttOpen;
   }
};
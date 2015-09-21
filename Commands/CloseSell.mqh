class CCloseSell : public COrderCommand
{
public:
   CCloseSell()
   {
      trade_direction = tdShort;
      transaction_type = ttClose;
   }
};
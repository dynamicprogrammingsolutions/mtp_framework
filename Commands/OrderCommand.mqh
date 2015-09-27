class COrderCommand : public CObject
{
public:

   static int CommandOpenBuy;
   static int CommandOpenSell;
   static int CommandCloseBuy;
   static int CommandCloseSell;
   static int CommandCloseAll;
   
};

int COrderCommand::CommandOpenBuy = 0;
int COrderCommand::CommandOpenSell = 0;
int COrderCommand::CommandCloseBuy = 0;
int COrderCommand::CommandCloseSell = 0;
int COrderCommand::CommandCloseAll = 0;

class COrderCommand : public CAppObject
{
public:

   static int CommandOpenBuy;
   static int CommandOpenSell;
   static int CommandCloseBuy;
   static int CommandCloseSell;
   static int CommandCloseAll;
   
   TraitAppAccess
   TraitHasCommands
   
   void GetCommands(int& commands[])
   {
     ArrayResize(commands,5);
     commands[0] = CommandId(CommandOpenBuy);
     commands[1] = CommandId(CommandOpenSell);
     commands[2] = CommandId(CommandCloseBuy);
     commands[3] = CommandId(CommandCloseSell);
     commands[4] = CommandId(CommandCloseAll);
   }
   
   /*int CommandId(int& id)
   {
     return App().commandmanager.SetId(id);
   }
   
   void CommandRegister(int& id, CAppObject* callback)
   {
     App().commandmanager.Register(id,callback);
   }
   
   void CommandRegisterOnly(int id, CAppObject* callback)
   {
     App().commandmanager.RegisterOnly(id,callback);
   }
   
   CObject* CommandSend(const int id, CObject* object = NULL)
   {
      return App().commandmanager.Send(id,object);
   }
   
   virtual void CommandListener(CAppObject* object)
   {
     int commands[];
     GetCommands(commands);
     for (int i = 0; i < ArraySize(commands); i++) {
         CommandRegisterOnly(commands[i],object);
     }
   }*/
   
   
};

int COrderCommand::CommandOpenBuy = 0;
int COrderCommand::CommandOpenSell = 0;
int COrderCommand::CommandCloseBuy = 0;
int COrderCommand::CommandCloseSell = 0;
int COrderCommand::CommandCloseAll = 0;

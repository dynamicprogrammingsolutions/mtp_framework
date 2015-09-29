//
#define TraitHasCommands int CommandId(int& _id) { return App().commandmanager.SetId(_id); } void CommandRegister(int& _id, CAppObject* callback) { App().commandmanager.Register(_id,callback); } void CommandRegisterOnly(int _id, CAppObject* callback) { App().commandmanager.RegisterOnly(_id,callback); } CObject* CommandSend(const int _id, CObject* object = NULL) { return App().commandmanager.Send(_id,object); } virtual void CommandHandler(CAppObject* object) { int commands[]; GetCommands(commands); for (int i = 0; i < ArraySize(commands); i++) { CommandRegisterOnly(commands[i],object); } }

/*
// Requires:

void GetCommands(int& commands[])
{
  ArrayResize(commands,5);
  commands[0] = CommandId(CommandOpenBuy);
  commands[1] = CommandId(CommandOpenSell);
  commands[2] = CommandId(CommandCloseBuy);
  commands[3] = CommandId(CommandCloseSell);
  commands[4] = CommandId(CommandCloseAll);
}
  
*/

/*
//Original Code
//Converted by: http://www.textfixer.com/tools/remove-line-breaks.php


   int CommandId(int& _id)
   {
     return App().commandmanager.SetId(_id);
   }
   
   void CommandRegister(int& _id, CAppObject* callback)
   {
     App().commandmanager.Register(_id,callback);
   }
   
   void CommandRegisterOnly(int _id, CAppObject* callback)
   {
     App().commandmanager.RegisterOnly(_id,callback);
   }
   
   CObject* CommandSend(const int _id, CObject* object = NULL)
   {
      return App().commandmanager.Send(_id,object);
   }
   
   virtual void CommandHandler(CAppObject* object)
   {
     int commands[];
     GetCommands(commands);
     for (int i = 0; i < ArraySize(commands); i++) {
         CommandRegisterOnly(commands[i],object);
     }
   }
   
*/
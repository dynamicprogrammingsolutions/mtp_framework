#include "..\Loader.mqh"

class CEntryMethodBase : public CEntryMethodInterface
{
public:
   virtual int Type() const { return classEntryMethodBase; }

   TraitAppAccess

   COrderCommand* command_open_buy;
   COrderCommand* command_open_sell;
   COrderCommand* command_close_buy;
   COrderCommand* command_close_sell;
   COrderCommand* command_close_all;
   
   COrderManager* ordermanager;
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);
      command_open_buy = new COrderCommand(commandOpenBuy);
      command_open_sell = new COrderCommand(commandOpenSell);
      command_close_buy = new COrderCommand(commandCloseBuy);
      command_close_sell = new COrderCommand(commandCloseSell);
      command_close_all = new COrderCommand(commandCloseAll);
   }
   
   virtual void OnCloseSellSignal(bool valid)
   {
      App().commandmanager.Send(COrderCommand::Command, command_close_sell);
   }
   
   virtual void OnCloseBuySignal(bool valid)
   {
      App().commandmanager.Send(COrderCommand::Command, command_close_buy);
   }
   
   virtual void OnCloseAllSignal(bool valid)
   {
      App().commandmanager.Send(COrderCommand::Command, command_close_all);
   }
   
   virtual void OnCloseBuyOpposite(bool valid)
   {
      App().commandmanager.Send(COrderCommand::Command, command_close_sell);
   }
   
   virtual void OnCloseSellOpposite(bool valid)
   {
      App().commandmanager.Send(COrderCommand::Command, command_close_buy);
   }
   
   virtual void OnBuySignal(bool valid)
   {
      if (CloseOpposite()) OnCloseBuyOpposite(valid);
      if (BuySignalFilter(valid)) {
         App().commandmanager.Send(COrderCommand::Command, command_open_buy);
      }
   }
   virtual void OnSellSignal(bool valid)
   {   
      if (CloseOpposite()) OnCloseSellOpposite(valid);
      if (SellSignalFilter(valid)) {
         App().commandmanager.Send(COrderCommand::Command, command_open_sell);
      }
   }
   
   virtual bool CloseOpposite()
   {
      return false;
   }
   
   virtual bool BuySignalFilter(bool valid)
   {
      return valid;
   }
   
   virtual bool SellSignalFilter(bool valid)
   {
      return valid;
   }

};
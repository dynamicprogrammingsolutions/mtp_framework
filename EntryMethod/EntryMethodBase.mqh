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
   
   COrderManager* ordermanager;
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);
      command_open_buy = new COpenBuy(false);
      command_open_sell = new COpenSell(false);
      command_close_buy = new CCloseBuy(false);
      command_close_sell = new CCloseSell(false);
   }
   
   virtual void OnCloseSellSignal()
   {
      App().commandmanager.Send(COrderCommand::Command, command_close_sell);
   }
   
   virtual void OnCloseBuySignal()
   {
      App().commandmanager.Send(COrderCommand::Command, command_close_buy);
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
      if (valid && BuySignalFilter()) {
         App().commandmanager.Send(COrderCommand::Command, command_open_buy);
      }
   }
   virtual void OnSellSignal(bool valid)
   {   
      if (CloseOpposite()) OnCloseSellOpposite(valid);
      if (valid && SellSignalFilter()) {
         App().commandmanager.Send(COrderCommand::Command, command_open_sell);
      }
   }
   
   virtual bool CloseOpposite()
   {
      return false;
   }
   
   virtual bool BuySignalFilter()
   {
      return true;
   }
   
   virtual bool SellSignalFilter()
   {
      return true;
   }

};
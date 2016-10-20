#include "..\Loader.mqh"

enum ENUM_ORDER_COMMAND{
   commandOrderNone,
   commandOpenOrder,
   commandOpenBuy,
   commandOpenSell,
   commandOpenBuyLimit,
   commandOpenSellLimit,
   commandOpenBuyStop,
   commandOpenSellStop,
   commandCloseBuy,
   commandCloseSell,
   commandCloseAll,
   commandCloseLast,
};

class COrderCommand : public CAppObject
{
public:
   TraitGetType(classOrderCommand)

   /*
   static int CommandOpenOrder;
   static int CommandOpenBuy;
   static int CommandOpenSell;
   static int CommandOpenBuyLimit;
   static int CommandOpenSellLimit;
   static int CommandOpenBuyStop;
   static int CommandOpenSellStop;
   static int CommandCloseBuy;
   static int CommandCloseSell;
   static int CommandCloseAll;
   static int CommandCloseLast;
   */
   
   CStopsCalcInterface* entry;
   CStopsCalcInterface* sl;
   CStopsCalcInterface* tp;
   CMoneyManagementInterface* mm;
   string comment;
   ENUM_ORDERSELECT select;
   ENUM_ORDER_TYPE cmd;
   
   COrderCommand()
   {
   }
   
   COrderCommand(ENUM_ORDER_TYPE _cmd)
   {
      this.cmd = _cmd;
   }
   
   COrderCommand(ENUM_ORDERSELECT _select)
   {
      this.select = _select;
   }
   
   static bool CheckObject(CObject* commandobj)
   {
      if (isset(commandobj) && commandobj.Type() == classOrderCommand) return true;
      return false;
   }
   
   static ENUM_ORDER_TYPE GetCmd(CObject* commandobj, ENUM_ORDER_TYPE defaultcmd)
   {
      COrderCommand* command = NULL;
      if (isset(commandobj) && commandobj.Type() == classOrderCommand) command = commandobj;
      if (command != NULL) return command.cmd;
      return defaultcmd;
   }
   
   static bool GetCmd(CObject* commandobj, ENUM_ORDER_TYPE& cmd)
   {
      COrderCommand* command = NULL;
      if (isset(commandobj) && commandobj.Type() == classOrderCommand) command = commandobj;
      if (command != NULL) {
         cmd = command.cmd;
         return true;
      }
      return false;
   }
   
   static ENUM_ORDERSELECT GetSelect(CObject* commandobj, ENUM_ORDERSELECT defaultselect)
   {
      COrderCommand* command = NULL;
      if (isset(commandobj) && commandobj.Type() == classOrderCommand) command = commandobj;
      if (command != NULL) return command.select;
      return defaultselect;
   }
   
   template<typename T>
   static shared_ptr<CStopsCalcInterface> GetEntry(CObject* commandobj, shared_ptr<T> &defaultentry)
   {
      COrderCommand* command = NULL;
      if (isset(commandobj) && commandobj.Type() == classOrderCommand) command = commandobj;
      if (command != NULL && isset(command.entry)) return command.entry;
      CSharedPtr<CStopsCalcInterface> def;
      def.Assign(defaultentry);
      return def;
   }
   
   template<typename T>
   static shared_ptr<CStopsCalcInterface> GetSL(CObject* commandobj, shared_ptr<T> &defaultsl)
   {
      COrderCommand* command = NULL;
      if (isset(commandobj) && commandobj.Type() == classOrderCommand) command = commandobj;
      if (command != NULL && isset(command.sl)) return command.sl;
      CSharedPtr<CStopsCalcInterface> def;
      def.Assign(defaultsl);
      return def;
   }
   
   template<typename T>
   static shared_ptr<CStopsCalcInterface> GetTP(CObject* commandobj, shared_ptr<T> &defaulttp)
   {
      COrderCommand* command = NULL;
      if (isset(commandobj) && commandobj.Type() == classOrderCommand) command = commandobj;
      if (command != NULL && isset(command.tp)) return command.tp;
      CSharedPtr<CStopsCalcInterface> def;
      def.Assign(defaulttp);
      return def;
   }
   
   template<typename T>
   static shared_ptr<CMoneyManagementInterface> GetMM(CObject* commandobj, shared_ptr<T> &defaultmm)
   {
      COrderCommand* command = NULL;
      if (isset(commandobj) && commandobj.Type() == classOrderCommand) command = commandobj;
      if (command != NULL && isset(command.mm)) return command.mm;
      CSharedPtr<CMoneyManagementInterface> def;
      def.Assign(defaultmm);
      return def;
   }
   
};

/*
int COrderCommand::CommandOpenOrder = 0;
int COrderCommand::CommandOpenBuy = 0;
int COrderCommand::CommandOpenSell = 0;
int COrderCommand::CommandOpenBuyLimit = 0;
int COrderCommand::CommandOpenSellLimit = 0;
int COrderCommand::CommandOpenBuyStop = 0;
int COrderCommand::CommandOpenSellStop = 0;
int COrderCommand::CommandCloseBuy = 0;
int COrderCommand::CommandCloseSell = 0;
int COrderCommand::CommandCloseAll = 0;
int COrderCommand::CommandCloseLast = 0;
*/
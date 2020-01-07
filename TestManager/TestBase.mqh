//
#include "Loader.mqh"

class CTestBase : public CTestInterface
{
private:
   bool started;
   bool started_ontick;
   bool ended;
   datetime started_at;
   datetime started_ontick_at;
   bool failed;
   string test_name;
public:
   bool logall;

   virtual bool IsStarted()
   {
      return started;
   }
   
   virtual bool IsStartedOnTick()
   {
      return started_ontick;
   }
   
   virtual bool IsRunning()
   {
      return started && !ended;
   }
   
   virtual bool IsEnded()
   {
      return ended;
   }

   virtual void Start()
   {
      started = true;
      started_at = TimeCurrent();
      if (!OnBegin()) Stop();
   }
   
   virtual void StartOnTick()
   {
      started_ontick = true;
      started_ontick_at = TimeCurrent();
      if (!OnBeginOnTick()) Stop();
   }

   virtual void Stop()
   {
      AssertNoError();
      Check();
      ended = true;
      OnEnd();
   }
   
   virtual bool OnBegin()
   {
      return true;
   }

   virtual bool OnBeginOnTick()
   {
      return true;
   }
   
   virtual void OnEnd()
   {
      
   }
   
   void TestName(string name)
   {
      AssertNoError();
      Check();
      test_name = name;
      if (logall) Print("Test: "+name);
   }
   
   bool Check()
   {
      if (failed) {
         Print("FAILED test: "+test_name);
         failed = false;
         return false;
      }
      return true;
   }
   
   bool Check(string stepname)
   {
      if (failed) {
         Print("FAILED test: "+test_name+" AT "+stepname);
         failed = false;
         return false;
      }
      return true;
   }
   
   bool AssertWarning()
   {
      return AssertEqual(CHECK_WARNING,true,"warning",false);
   }
   
   bool AssertError()
   {
      return AssertEqual(CHECK_ERROR,true,"error",false);
   }
   
   bool AssertNoError()
   {
      return (AssertEqual(CHECK_ERROR,false,"error",false) &&
      AssertEqual(CHECK_WARNING,false,"warning",false));
   }

   
   bool Assert(bool assertion, string name, string info = NULL, bool print_on_success = false, bool print_on_fail = true)
   {
      if (assertion) {
         if (print_on_success) Print("success: Assertion '"+name+"' "+(info!=NULL?(" ("+info+")"):""));
         return true;
      } else {
         if (print_on_fail) Print("FAIL: Assertion '"+name+"' "+(info!=NULL?(" ("+info+")"):""));
         failed = true;
         return false;
      }
   }
   bool AssertLarger(double value, double compare, string name)
   {
      return Assert(value > compare,name,(string)value+" > "+(string)compare);
   }
   bool AssertLargerOrEqual(double value, double compare, string name)
   {
      return Assert(value >= compare,name,(string)value+" >= "+(string)compare);
   }
   bool AssertSmaller(double value, double compare, string name)
   {
      return Assert(value < compare,name,(string)value+" < "+(string)compare);
   }
   bool AssertSmallerOrEqual(double value, double compare, string name)
   {
      return Assert(value <= compare,name,(string)value+" <= "+(string)compare);
   }
   template<typename T>
   bool AssertEqual(T value, T compare, string name, bool print_on_success = true)
   {
      return Assert(value==compare,name,Conc(value," == ",compare),print_on_success);
   }
   template<typename T>
   bool AssertNotEqual(T value, T compare, string name, bool print_on_success = true)
   {
      return Assert(value!=compare,name,Conc(value," != ",compare),print_on_success);
   }

   template<typename T>
   bool AssertEqualEnum(T value, T compare, string name, bool print_on_success = true)
   {
      return Assert(value==compare,name,Conc(EnumToString(value)," == ",EnumToString(compare)),print_on_success);
   }

   template<typename T>
   bool AssertNotEqualEnum(T value, T compare, string name, bool print_on_success = true)
   {
      return Assert(value!=compare,name,Conc(EnumToString(value)," != ",EnumToString(compare)),print_on_success);
   }

   bool AssertEqualD(double value, double compare, string name)
   {
      return Assert(q(value,compare),name,(string)value+" == "+(string)compare);
   }
   bool AssertIsSet(CAppObject* object, string name)
   {
      return Assert(isset(object),name,name+" is set");
   }
   bool AssertIsNotSet(CAppObject* object, string name)
   {
      return Assert(!isset(object),name,name+" is not set");
   }
   bool AssertIsNull(CAppObject* object, string name)
   {
      return Assert(CheckPointer(object)==NULL,name,name+" is null");
   }
   bool AssertIsNotNull(CAppObject* object, string name)
   {
      return Assert(CheckPointer(object)!=NULL,name,name+" is not null");
   }
   
};
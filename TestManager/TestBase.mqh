//
#include "Loader.mqh"

class CTestBase : public CTestInterface
{
private:
   bool started;
   bool ended;
   datetime started_at;
public:
   virtual bool IsStarted()
   {
      return started;
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

   virtual void Stop()
   {
      ended = true;
      OnEnd();
   }
   
   virtual bool OnBegin()
   {
      return false;
   }
   
   virtual void OnEnd()
   {
      
   }
   
   bool Assert(bool assertion, string name, string info = NULL)
   {
      if (assertion) {
         Print("Assertion '"+name+"' success"+(info!=NULL?(" ("+info+")"):""));
         return true;
      } else {
         Print("Assertion '"+name+"' failed"+(info!=NULL?(" ("+info+")"):""));
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
   bool AssertEqual(T value, T compare, string name)
   {
      return Assert(value==compare,name,(string)value+" == "+(string)compare);
   }

   bool AssertEqualD(double value, double compare, string name)
   {
      return Assert(q(value,compare),name,(string)value+" == "+(string)compare);
   }
   bool AssertIsSet(CAppObject* object, string name)
   {
      return Assert(isset(object),name,name+" is not null");
   }
};
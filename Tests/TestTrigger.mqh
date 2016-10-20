#include "Loader.mqh"

enum ENUM_TEST_TRIGGER_ID
{
   testtriggerFirst,
   testtriggerSecond,
   testtriggerThird,
};

class CTestTrigger : public CTestBase
{
public:
   TraitGetType(classTestTrigger)
   TraitAppAccess
   
   shared_ptr<CAppObject> cb;
   
   int function_called;
   int id_called;
   
   virtual void callback(const int id) { function_called = 26; id_called = id; }

   CTestTrigger() :
      cb(new CTestCallbackObject(this))
   {
   
   }
      
   void Reset()
   {
      function_called = 0;
      id_called = 0;
   }
   
   bool AssertCallback(const int function_id, const int id = -1)
   {
      bool ret = true;
      ret &= AssertEqual(function_called,function_id,"function",false);
      if (id != -1) ret &= AssertEqual(id_called,id,"id",false);
      Reset();
      return ret;
   }
   
   void TestRegister()
   {
      TestName("Test Trigger Register");
      int trigger = 1;
      int classid = classLast+1;
      int save_trigger_count = App().trigger.Count();
      int called_id = 1;
      {
         TestName("Trigger register using ptr");
         AssertEqual(App().trigger.Register(classid,trigger,cb,called_id),true,"trigger",false);
         AssertEqual(trigger,1,"trigger",false);
         App().trigger.Trigger(classid,trigger);
         AssertCallback(21,called_id);
         App().trigger.DeRegister(classid,trigger);
      }
      classid++;
      called_id++;
      {
         TestName("Trigger register using builtin pointer");
         AssertEqual(App().trigger.Register(classid,trigger,cb.get(),called_id),true,"trigger",false);
         AssertEqual(trigger,1,"trigger",false);
         App().trigger.Trigger(classid,trigger);
         AssertCallback(21,called_id);
         App().trigger.DeRegister(classid,trigger);
      }
      classid++;
      called_id++;
      {
         TestName("Trigger register using builtin object");
         CTestCallbackObject thiscb(this);
         AssertEqual(App().trigger.Register(classid,trigger,thiscb,called_id),true,"trigger",false);
         AssertEqual(trigger,1,"trigger",false);
         App().trigger.Trigger(classid,trigger);
         AssertCallback(21,called_id);
         App().trigger.DeRegister(classid,trigger);
      }
      classid++;
      called_id++;
      {
         TestName("Trigger using fixed trigger id");
         
         int trigger1 = 3;
         int trigger2 = 5;
         
         App().trigger.Register(classid,trigger1,cb,called_id+1);
         App().trigger.Register(classid,trigger2,cb,called_id+2);
         
         AssertEqual(trigger1,3,"trigger",false);
         AssertEqual(trigger2,5,"trigger",false);
         
         App().trigger.Trigger(classid,trigger1);
         AssertCallback(21,called_id+1);
         App().trigger.Trigger(classid,trigger2);
         AssertCallback(21,called_id+2);
         
         App().trigger.DeRegister(classid,trigger1);
         App().trigger.DeRegister(classid,trigger2);
      }

      classid++;
      called_id++;
      {
         TestName("Trigger using enum trigger id");
         
         int itesttriggerFirst = testtriggerFirst;
         int itesttriggerThird = testtriggerThird;
         
         App().trigger.Register(classid,testtriggerFirst,cb,called_id+1);
         App().trigger.Register(classid,testtriggerThird,cb,called_id+2);
         
         //AssertEqual(itesttriggerFirst,(int)testtriggerFirst,"trigger",false);
         //AssertEqual(itesttriggerThird,(int)testtriggerThird,"trigger",false);
         
         
         App().trigger.Trigger(classid,testtriggerFirst);
         AssertCallback(21,called_id+1);
         App().trigger.Trigger(classid,testtriggerThird);
         AssertCallback(21,called_id+2);
         
         App().trigger.DeRegister(classid,testtriggerFirst);
         App().trigger.DeRegister(classid,testtriggerThird);
      }
      
      classid++;
      called_id++;
      {
         TestName("Trigger using dynamic trigger id");
         
         int trigger1;
         int trigger2;
         
         App().trigger.Register(classid,trigger1,cb,called_id+1);
         App().trigger.Register(classid,trigger2,cb,called_id+2);
         
         AssertEqual(trigger1,1,"trigger",false);
         AssertEqual(trigger2,2,"trigger",false);
         
         App().trigger.Trigger(classid,trigger1);
         AssertCallback(21,called_id+1);
         App().trigger.Trigger(classid,trigger2);
         AssertCallback(21,called_id+2);
         
         App().trigger.DeRegister(classid,trigger1);
         App().trigger.DeRegister(classid,trigger2);
      }
      
      classid++;
      called_id++;
      {
         TestName("Test Deregister trigger");
         
         int trigger1 = 7;
         
         App().trigger.Register(classid,trigger1,cb,called_id+1);
         
         AssertEqual(trigger1,7,"trigger",false);
         
         App().trigger.Trigger(classid,trigger1);
         AssertCallback(21,called_id+1);
         
         App().trigger.DeRegister(classid,trigger1);

         App().trigger.Trigger(classid,trigger1);
         AssertCallback(0,0);

      }

      classid++;
      called_id++;
      {
         TestName("Test Deregister classid");
         
         int trigger1 = 7;
         
         App().trigger.Register(classid,trigger1,cb,called_id+1);
         
         AssertEqual(trigger1,7,"trigger",false);
         
         App().trigger.Trigger(classid,trigger1);
         AssertCallback(21,called_id+1);
         
         App().trigger.DeRegister(classid);

         App().trigger.Trigger(classid,trigger1);
         AssertCallback(0,0);

      }
      AssertEqual(App().trigger.Count(),save_trigger_count,"trigger count",false);
   }
   
   void TestTrigger()
   {
      TestName("Test Trigger Register");
      int trigger = 1;
      int classid = classLast+1;
      int save_trigger_count = App().trigger.Count();
      int called_id = 1;
      {
         App().trigger.Register(classid,trigger,cb,called_id);

         // Calling by value
         TestName("Test Calling By Value");
         
         App().trigger.Trigger(classid,trigger,true);
         AssertCallback(1,called_id);
         App().trigger.Trigger(classid,trigger,1);
         AssertCallback(6,called_id);
         App().trigger.Trigger(classid,trigger,1.0);
         AssertCallback(11,called_id);
         App().trigger.Trigger(classid,trigger,shared_ptr<CAppObject>::make_shared(new CAppObject));
         AssertCallback(16,called_id);
         App().trigger.Trigger(classid,trigger);
         AssertCallback(21,called_id);

         // Testing all functions

         int funcid = 0;
         
         {
            bool param = true;

            TestName("Testing Function "+(string)(funcid+1));

            App().trigger.Trigger(classid,trigger,param);
            AssertCallback(++funcid,called_id);

            CAppObject *retobj = App().trigger.TriggerObj(classid,trigger,param).get();
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retobj.get().Id(),retobj.Id(),"return object",false);
   
            bool retbool = App().trigger.TriggerBool(classid,trigger,param);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retbool,retbool,"return bool",false);
   
            double retdouble = App().trigger.TriggerDouble(classid,trigger,param);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retdouble,retdouble,"return double",false);
   
            int retint = App().trigger.TriggerInt(classid,trigger,param);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retint,retint,"return int",false);
         }
         
         {
            int param = 1;

            TestName("Testing Function "+(string)(funcid+1));

            App().trigger.Trigger(classid,trigger,param);
            AssertCallback(++funcid,called_id);

            CAppObject *retobj = App().trigger.TriggerObj(classid,trigger,param).get();
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retobj.get().Id(),retobj.Id(),"return object",false);
   
            bool retbool = App().trigger.TriggerBool(classid,trigger,param);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retbool,retbool,"return bool",false);
   
            double retdouble = App().trigger.TriggerDouble(classid,trigger,param);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retdouble,retdouble,"return double",false);
   
            int retint = App().trigger.TriggerInt(classid,trigger,param);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retint,retint,"return int",false);
         }
         
         {
            double param = 1.0;

            TestName("Testing Function "+(string)(funcid+1));

            App().trigger.Trigger(classid,trigger,param);
            AssertCallback(++funcid,called_id);

            CAppObject *retobj = App().trigger.TriggerObj(classid,trigger,param).get();
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retobj.get().Id(),retobj.Id(),"return object",false);
   
            bool retbool = App().trigger.TriggerBool(classid,trigger,param);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retbool,retbool,"return bool",false);
   
            double retdouble = App().trigger.TriggerDouble(classid,trigger,param);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retdouble,retdouble,"return double",false);
   
            int retint = App().trigger.TriggerInt(classid,trigger,param);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retint,retint,"return int",false);
         }
         
         {
            PAppObject param = new CAppObject;

            TestName("Testing Function "+(string)(funcid+1));

            App().trigger.Trigger(classid,trigger,param);
            AssertCallback(++funcid,called_id);

            CAppObject *retobj = App().trigger.TriggerObj(classid,trigger,param).get();
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retobj.get().Id(),retobj.Id(),"return object",false);
   
            bool retbool = App().trigger.TriggerBool(classid,trigger,param);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retbool,retbool,"return bool",false);
   
            double retdouble = App().trigger.TriggerDouble(classid,trigger,param);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retdouble,retdouble,"return double",false);
   
            int retint = App().trigger.TriggerInt(classid,trigger,param);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retint,retint,"return int",false);
         }
         
         {
            TestName("Testing Function "+(string)(funcid+1));

            App().trigger.Trigger(classid,trigger);
            AssertCallback(++funcid,called_id);

            CAppObject *retobj = App().trigger.TriggerObj(classid,trigger).get();
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retobj.get().Id(),retobj.Id(),"return object",false);
   
            bool retbool = App().trigger.TriggerBool(classid,trigger);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retbool,retbool,"return bool",false);
   
            double retdouble = App().trigger.TriggerDouble(classid,trigger);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retdouble,retdouble,"return double",false);
   
            int retint = App().trigger.TriggerInt(classid,trigger);
            AssertCallback(++funcid,called_id);
            AssertEqual(((CTestCallbackObject*)cb.get()).retint,retint,"return int",false);
         }
         
         App().trigger.DeRegister(classid,trigger);
         
      }
      {      
         {
            TestName("Testing TriggerBoolOr case1");
            App().trigger.Register(classid,trigger,cb,100);
            App().trigger.Register(classid,trigger,cb,101);
            bool expected_result = true;
            AssertEqual(App().trigger.TriggerBoolOr(classid,trigger),expected_result,"TriggerBoolOr result",false);
            AssertCallback(23);
            AssertEqual(App().trigger.TriggerBoolOr(classid,trigger,true),expected_result,"TriggerBoolOr result",false);
            AssertCallback(3);
            AssertEqual(App().trigger.TriggerBoolOr(classid,trigger,1),expected_result,"TriggerBoolOr result",false);
            AssertCallback(8);
            AssertEqual(App().trigger.TriggerBoolOr(classid,trigger,1.0),expected_result,"TriggerBoolOr result",false);
            AssertCallback(13);
            AssertEqual(App().trigger.TriggerBoolOr(classid,trigger,shared_ptr<CAppObject>::make_shared(new CAppObject)),expected_result,"TriggerBoolOr result",false);
            AssertCallback(18);
            App().trigger.DeRegister(classid,trigger);         
         }
         {
            TestName("Testing TriggerBoolOr case2");
            App().trigger.Register(classid,trigger,cb,100);
            App().trigger.Register(classid,trigger,cb,100);
            bool expected_result = false;
            AssertEqual(App().trigger.TriggerBoolOr(classid,trigger),expected_result,"TriggerBoolOr result",false);
            AssertCallback(23);
            AssertEqual(App().trigger.TriggerBoolOr(classid,trigger,true),expected_result,"TriggerBoolOr result",false);
            AssertCallback(3);
            AssertEqual(App().trigger.TriggerBoolOr(classid,trigger,1),expected_result,"TriggerBoolOr result",false);
            AssertCallback(8);
            AssertEqual(App().trigger.TriggerBoolOr(classid,trigger,1.0),expected_result,"TriggerBoolOr result",false);
            AssertCallback(13);
            AssertEqual(App().trigger.TriggerBoolOr(classid,trigger,shared_ptr<CAppObject>::make_shared(new CAppObject)),expected_result,"TriggerBoolOr result",false);
            AssertCallback(18);
            App().trigger.DeRegister(classid,trigger);         
         }
         {
            TestName("Testing TriggerBoolAnd case1");
            App().trigger.Register(classid,trigger,cb,100);
            App().trigger.Register(classid,trigger,cb,101);
            bool expected_result = false;
            AssertEqual(App().trigger.TriggerBoolAnd(classid,trigger),expected_result,"TriggerBoolOr result",false);
            AssertCallback(23);
            AssertEqual(App().trigger.TriggerBoolAnd(classid,trigger,true),expected_result,"TriggerBoolOr result",false);
            AssertCallback(3);
            AssertEqual(App().trigger.TriggerBoolAnd(classid,trigger,1),expected_result,"TriggerBoolOr result",false);
            AssertCallback(8);
            AssertEqual(App().trigger.TriggerBoolAnd(classid,trigger,1.0),expected_result,"TriggerBoolOr result",false);
            AssertCallback(13);
            AssertEqual(App().trigger.TriggerBoolAnd(classid,trigger,shared_ptr<CAppObject>::make_shared(new CAppObject)),expected_result,"TriggerBoolOr result",false);
            AssertCallback(18);
            App().trigger.DeRegister(classid,trigger);         
         }
         {
            TestName("Testing TriggerBoolAnd case2");
            App().trigger.Register(classid,trigger,cb,101);
            App().trigger.Register(classid,trigger,cb,101);
            bool expected_result = true;
            AssertEqual(App().trigger.TriggerBoolAnd(classid,trigger),expected_result,"TriggerBoolOr result",false);
            AssertCallback(23);
            AssertEqual(App().trigger.TriggerBoolAnd(classid,trigger,true),expected_result,"TriggerBoolOr result",false);
            AssertCallback(3);
            AssertEqual(App().trigger.TriggerBoolAnd(classid,trigger,1),expected_result,"TriggerBoolOr result",false);
            AssertCallback(8);
            AssertEqual(App().trigger.TriggerBoolAnd(classid,trigger,1.0),expected_result,"TriggerBoolOr result",false);
            AssertCallback(13);
            AssertEqual(App().trigger.TriggerBoolAnd(classid,trigger,shared_ptr<CAppObject>::make_shared(new CAppObject)),expected_result,"TriggerBoolOr result",false);
            AssertCallback(18);
            App().trigger.DeRegister(classid,trigger);         
         }
      }
      
      AssertEqual(App().trigger.Count(),save_trigger_count,"trigger count",false);
   }
   
   void TestMacros()
   {
      TestName("Test Macros");
      int trigger = 1;
      int classid = classLast+1;
      int save_trigger_count = App().trigger.Count();
      int called_id = 1;
      {
         ((CTestCallbackObject*)cb.get()).listen(this.Type(),trigger,called_id);
         TRIGGER(trigger);
         AssertCallback(18,called_id);
         App().trigger.DeRegister(this.Type(),trigger);
      }
      
      {
      
         App().trigger.Register(this.Type(),trigger,cb,called_id);
         
         TRIGGER_CONFIRM(this.Type(),trigger);
         AssertCallback(23,called_id);

         TRIGGER_CONFIRM_P(this.Type(),trigger,true);
         AssertCallback(3,called_id);
         
         /*TRIGGER_CONFIRM_SP(trigger,new CAppObject);
         AssertCallback(18,called_id);
         
         TRIGGER_CONFIRM_WP(trigger,this);
         AssertCallback(18,called_id);*/
         
         TRIGGER_CONFIRM_S(this.Type(),trigger);
         AssertCallback(18,called_id);
         
         TRIGGER_VOID(this.Type(),trigger);
         AssertCallback(21,called_id);
         
         TRIGGER_BOOL(this.Type(),trigger);
         AssertCallback(23,called_id);
         
         TRIGGER_INT(this.Type(),trigger);
         AssertCallback(25,called_id);
         
         TRIGGER_DOUBLE(this.Type(),trigger);
         AssertCallback(24,called_id);
         
         TRIGGER_OBJ(this.Type(),trigger);
         AssertCallback(22,called_id);

         TRIGGER_VOID_P(this.Type(),trigger,true);
         AssertCallback(1,called_id);
         
         TRIGGER_BOOL_P(this.Type(),trigger,true);
         AssertCallback(3,called_id);
         
         TRIGGER_INT_P(this.Type(),trigger,true);
         AssertCallback(5,called_id);
         
         TRIGGER_DOUBLE_P(this.Type(),trigger,true);
         AssertCallback(4,called_id);
         
         TRIGGER_OBJ_P(this.Type(),trigger,true);
         AssertCallback(2,called_id);
         
         App().trigger.DeRegister(this.Type(),trigger);

      }
      AssertEqual(App().trigger.Count(),save_trigger_count,"trigger count",false);
   }
   
   virtual bool OnBegin()
   {
      _DisableReportingInfo = true;
      Reset();
      TestRegister();
      TestTrigger();
      TestMacros();
      _DisableReportingInfo = false;
      return false;
   }
};

#define TEST_CALLBACK(__func__) { /*Print("cb "+__func__+" id: "+id);*/ testtrigger.get().function_called = __func__; testtrigger.get().id_called = id; }
#define TEST_CALLBACK_BOOL { switch(id) { case 100: return false; case 101: return true; case 102: return false; case 103: return true; } }

class CTestCallbackObject : public CAppObject
{
public:
   TraitAppAccess
   TraitGetType(classLast+1)

   shared_ptr<CAppObject> retobj;
   bool retbool;
   double retdouble;
   int retint;

   weak_ptr<CTestTrigger> testtrigger;
   CTestCallbackObject(CTestTrigger &_testtrigger) :
      testtrigger(_testtrigger),
      retobj(new CAppObject),
      retbool(true),
      retdouble(1.0),
      retint(1)
   {
   
   }
   
   void listen(int type, int signal, int funcid)
   {
      //App().trigger.Register(type,signal,this,funcid);
      LISTEN(type,signal,funcid);
   }
   
   virtual void callback(const int id, bool obj) { TEST_CALLBACK(1) return; }
   virtual PAppObject callback_obj(const int id, bool obj) { TEST_CALLBACK(2) return MakeAppObject(retobj.get()); }
   virtual bool callback_bool(const int id, bool obj) { TEST_CALLBACK(3) TEST_CALLBACK_BOOL return retbool; }
   virtual double callback_double(const int id, bool obj) { TEST_CALLBACK(4) return retdouble; }
   virtual int callback_int(const int id, bool obj) { TEST_CALLBACK(5) return retint; }

   virtual void callback(const int id, int obj) { TEST_CALLBACK(6) return; }
   virtual PAppObject callback_obj(const int id, int obj) { TEST_CALLBACK(7) return MakeAppObject(retobj.get()); }
   virtual bool callback_bool(const int id, int obj) { TEST_CALLBACK(8) TEST_CALLBACK_BOOL return retbool; }
   virtual double callback_double(const int id, int obj) { TEST_CALLBACK(9) return retdouble; }
   virtual int callback_int(const int id, int obj) { TEST_CALLBACK(10) return retint; }

   virtual void callback(const int id, double obj) { TEST_CALLBACK(11) return; }
   virtual PAppObject callback_obj(const int id, double obj) { TEST_CALLBACK(12) return MakeAppObject(retobj.get()); }
   virtual bool callback_bool(const int id, double obj) { TEST_CALLBACK(13) TEST_CALLBACK_BOOL return retbool; }
   virtual double callback_double(const int id, double obj) { TEST_CALLBACK(14) return retdouble; }
   virtual int callback_int(const int id, double obj) { TEST_CALLBACK(15) return retint; }

   virtual void callback(const int id, BAppObject &obj) { TEST_CALLBACK(16) return; }
   virtual PAppObject callback_obj(const int id, BAppObject &obj) { TEST_CALLBACK(17) return MakeAppObject(retobj.get()); }
   virtual bool callback_bool(const int id, BAppObject &obj) { TEST_CALLBACK(18) TEST_CALLBACK_BOOL return retbool; }
   virtual double callback_double(const int id, BAppObject &obj) { TEST_CALLBACK(19) return retdouble; }
   virtual int callback_int(const int id, BAppObject &obj) { TEST_CALLBACK(20) return retint; }

   virtual void callback(const int id) { TEST_CALLBACK(21) return; }
   virtual PAppObject callback_obj(const int id) { TEST_CALLBACK(22) return MakeAppObject(retobj.get()); }
   virtual bool callback_bool(const int id) { TEST_CALLBACK(23) TEST_CALLBACK_BOOL return retbool; }
   virtual double callback_double(const int id) { TEST_CALLBACK(24) return retdouble; }
   virtual int callback_int(const int id) { TEST_CALLBACK(25) return retint; }
   
   
};

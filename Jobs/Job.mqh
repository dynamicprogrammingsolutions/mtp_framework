//
#include "Loader.mqh"

class CJob : public CAppObject
{
protected:
   // Callback to use:
   // virtual bool callback_bool(const int id, BAppObject &obj)
   PAppObject callback;
   int callback_id;
   PAppObject parameter;
   int max_tries;
   int sleep;
   bool delay;
public:
   bool executed;
   int tries;
   datetime last_try;
   bool failed;
public:
   CJob() :
      parameter(GetPointer(this)),
      max_tries(3),
      sleep(1),
      delay(false),
      last_try(0),
      tries(0)
   {}
   CJob(CAppObject* in_callback, int in_callback_id, CAppObject* in_parameter, int in_max_tries, int in_sleep, bool in_delay=false) :
      callback(in_callback),
      callback_id(in_callback_id),
      parameter(in_parameter),
      max_tries(in_max_tries),
      sleep(in_sleep),
      delay(in_delay),
      last_try(0),
      tries(0)
   {}
   CJob(CAppObject* in_callback, int in_callback_id, int in_max_tries, int in_sleep, bool in_delay=false) :
      callback(in_callback),
      callback_id(in_callback_id),
      parameter(GetPointer(this)),
      max_tries(in_max_tries),
      sleep(in_sleep),
      delay(in_delay),
      last_try(0),
      tries(0)
   {}
   bool Call()
   {
      if (executed) return true;
      return callback.get().callback_bool(callback_id,parameter);
   }
   bool Execute()
   {
      if (failed) return true;
      if (tries > 0) {
         if (tries >= max_tries) { failed = true; return true; }
         if (TimeCurrent()-last_try < delay) {
            return false;
         }
      }
      bool success = Call();
      if (success) {
         executed = true;
         Print("job executed successfully");
         return true;
      } else {
         last_try = TimeCurrent();
         tries++;
         if (tries >= max_tries) { failed = true; Print("job failed (tries: "+tries); return true; }
         Print("job execution didn't succeed tries: "+tries+"/"+max_tries);
         return false;
      }
   }
   
};
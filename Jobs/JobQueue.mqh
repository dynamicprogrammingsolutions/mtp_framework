//
#include "Loader.mqh"

class CJobQueue : public CServiceProvider
{
protected:
   CArrayObject<CJob> jobs;
public:
   bool NewJob(CJob* job)
   {
      jobs.Add(job);
      int idx = jobs.Total()-1;
      return Execute(idx);
   }

   bool Execute(int idx)
   {
      CJob* job = jobs.At(idx);
      if (job.Execute()) {
         jobs.DeletePosition(idx);
         return true;
      } else {
         return false;
      }
   }
   
   void ExecuteAll()
   {
      int idx;
      CJob* job;
      while (jobs.ForEach(job,idx,true)) {
         Execute(idx-1);
      }
      idx = 0;
      while (jobs.ForEachBackward(job,idx,false)) {
         if (job == NULL) jobs.Delete(idx-1);
      }
   }
   virtual void OnTick()
   {
      if (jobs.Total() > 0) ExecuteAll();
   }
};
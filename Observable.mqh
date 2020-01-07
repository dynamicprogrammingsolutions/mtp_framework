#include "Loader.mqh"
#define OBSERVABLE_H

class CObservable : public CAppObject
{
protected:
   CArrayObject<CAppObject> observers;
   
public:
   void AddObserver(CAppObject* observer) {
      this.observers.Add(observer);
   }
   
   void Dispatch(const int event_id, CObject* signal) {
      int total = observers.Total();
      for (int i = 0; i < total; i++) {
         CAppObject* observer = observers.At(i);
         observer.EventCallback(event_id,signal);
      }
   }
   
};

class CObservableServiceProvider : public CServiceProvider
{
protected:
   CArrayObject<CAppObject> observers;
   
public:
   void AddObserver(CAppObject* observer) {
      this.observers.Add(observer);
   }
   
   void Dispatch(const int event_id, CObject* signal) {
      int total = observers.Total();
      for (int i = 0; i < total; i++) {
         CAppObject* observer = observers.At(i);
         observer.EventCallback(event_id,signal);
      }
   }
   
};
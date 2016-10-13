//

//#define TraitRefCount  int reference_count; virtual bool ReferenceCountActive() { return true; } virtual CAppObject* RefAdd() { reference_count++; return GetPointer(this); } virtual CAppObject* RefDel() { reference_count--; return GetPointer(this); } virtual void RefClean() { if (reference_count == 0) delete GetPointer(this); }

/*

   int reference_count;
   
   virtual bool ReferenceCountActive()
   {
      return true;
   }
   
   virtual CAppObject* RefAdd()
   {
      reference_count++;
      return GetPointer(this);
   }

   virtual CAppObject* RefDel()
   {
      reference_count--;
      return GetPointer(this);
   }

   virtual void RefClean()
   {
      if (reference_count == 0) delete GetPointer(this);
   }

*/
//

class CAttachedOrder : public COrderBase
{
public:
   virtual int Type() const { return classMT4AttachedOrder; }

public:
   string name;  
public: 
   static bool price_virtual_default_attached;

   CAttachedOrder()
   {
      this.price_virtual = CAttachedOrder::price_virtual_default_attached;
   }

   static bool IsAttached(const string comment) { return(StringFind(comment,"a=")>=0 && StringFind(comment,"n=")>=0); }
   
   virtual bool Save(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;
      //if (!file.WriteString(name)) return file.Error("name",__FUNCTION__);
      if (!COrderBase::Save(handle)) return file.Error("COrderBase",__FUNCTION__);
      return(true);
   }
   
   virtual bool Load(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;
      //if (!file.ReadString(name)) return file.Error("name",__FUNCTION__);
      if (!COrderBase::Load(handle)) return file.Error("COrderBase",__FUNCTION__);
      return(true);
   }
   
};

bool CAttachedOrder::price_virtual_default_attached = false;

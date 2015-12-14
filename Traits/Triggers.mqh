//

#define TRIGGERP(__signal__,__parameter__) (APP.triggers.Send(__signal__,__parameter__))

#define TRIGGERC(__signal__,__parameter__) (APP.triggers.Send(__signal__,__parameter__,true))

#define TRIGGER(__signal__) (APP.triggers.Send(__signal__,GetPointer(this)))

#define LISTEN(__signal__,__functionid__) APP.triggers.Register(__signal__,GetPointer(this),__functionid__)

#define HANDLER(__signal__,__callback__,__id__) APP.triggers.Register(__signal__,__callback__,__id__)

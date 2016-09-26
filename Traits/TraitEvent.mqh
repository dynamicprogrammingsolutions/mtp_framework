#define TraitEvent(__event__,__function__) static int __event__; virtual bool __function__() { return TRIGGER(__event__); }

local m={}
m["91909190"]={"Move",nil}
m["1419090"]={"LoadK",function(x) x.b=x.b-1 end}
m["91902690"]={"LoadBool",nil}
m["91902690291529"]={"LoadBool",function(x) x.c = 1 end}
m["13909091"]={"LoadNil",nil}
m["91909290"]={"GetUpval",nil}
m["91909390"]={"GetGlobal",function(x) x.b=x.b-1 end}
m["9190991909190"]={"GetTable",nil}
m["91909919090"]={"GetTable",function(x) x.c=x.c+(255) end}
m["93909190"]={"SetGlobal",function(x) x.b=x.b-1 end}
m["92909190"]={"SetUpval",nil}
m["9919091909190"]={"SetTable",nil}
m["99190919090"]={"SetTable",function(x) x.c=x.c+(255) end}
m["99190909190"]={"SetTable",function(x) x.b=x.b+(255) end}
m["991909090"]={"SetTable",function(x) x.b=x.b+(255) 
            x.c=x.c+(255)  end}
m["919033"]={"NewTable",nil}
m["909190911591990"]={"Self",function(x) x.c=x.c+(255) end}
m["90919091159199190"]={"Self",nil}
m["91901591909190"]={"Add",nil}
m["919015919090"]={"Add",function(x) x.c=x.c+(255) end}
m["919015909190"]={"Add",function(x) x.b=x.b+(255) end}
m["9190159090"]={"Add",function(x) x.b=x.b+(255) 
            x.c=x.c+(255)  end}
m["91901691909190"]={"Sub",nil}
m["919016919090"]={"Sub",function(x) x.c=x.c+(255) end}
m["919016909190"]={"Sub",function(x) x.b=x.b+(255) end}
m["9190169090"]={"Sub",function(x) x.b=x.b+(255) 
            x.c=x.c+(255)  end}
m["91901791909190"]={"Mul",nil}
m["919017919090"]={"Mul",function(x) x.c=x.c+(255) end}
m["919017909190"]={"Mul",function(x) x.b=x.b+(255) end}
m["9190179090"]={"Mul",function(x) x.b=x.b+(255) 
            x.c=x.c+(255)  end}
m["91901891909190"]={"Div",nil}
m["919018919090"]={"Div",function(x) x.c=x.c+(255) end}
m["919018909190"]={"Div",function(x) x.b=x.b+(255) end}
m["9190189090"]={"Div",function(x) x.b=x.b+(255) 
            x.c=x.c+(255)  end}
m["91901991909190"]={"Mod",nil}
m["919019919090"]={"Mod",function(x) x.c=x.c+(255) end}
m["919019909190"]={"Mod",function(x) x.b=x.b+(255) end}
m["9190199090"]={"Mod",function(x) x.b=x.b+(255) 
            x.c=x.c+(255)  end}
m["91902091909190"]={"Pow",nil}
m["919020919090"]={"Pow",function(x) x.c=x.c+(255) end}
m["919020909190"]={"Pow",function(x) x.b=x.b+(255) end}
m["9190209090"]={"Pow",function(x) x.b=x.b+(255) 
            x.c=x.c+(255)  end}
m["9190319190"]={"Unm",nil}
m["9190349190"]={"Not",nil}
m["9190289190"]={"Len",nil}
m["909113159032919190"]={"Concat",nil}
m["2990"]={"Jmp",function(x) x.b=x.b-(x.pc + 1) end}
m["101225919091902915292990"]={"Eq",function(x) x.b = x.a 
            x.a = 0  end}
m["1012259190902915292990"]={"Eq",function(x) x.b = x.a 
            x.a = 0 
            x.c=x.c+(255)  end}
m["1012259091902915292990"]={"Eq",function(x) x.b = x.a + 255 
            x.a = 0  end}
m["10122590902915292990"]={"Eq",function(x) x.b = x.a + 255 
            x.a = 0 
            x.c=x.c+(255)  end}
m["101226919091902915292990"]={"Eq",function(x) x.b = x.a 
            x.a = 1  end}
m["1012269190902915292990"]={"Eq",function(x) x.b = x.a 
            x.a = 1 
            x.c=x.c+(255)  end}
m["1012269091902915292990"]={"Eq",function(x) x.b = x.a + 255 
            x.a = 1  end}
m["10122690902915292990"]={"Eq",function(x) x.b = x.a + 255 
            x.a = 1 
            x.c=x.c+(255)  end}
m["2936352591909190901529"]={"Eq",function(x) x.b = x.a 
            x.a = 1  end}
m["101221919091902915292990"]={"Lt",function(x) x.b = x.a 
            x.a = 0  end}
m["1012219091902915292990"]={"Lt",function(x) x.b = x.a + 255 
            x.a = 0  end}
m["1012219190902915292990"]={"Lt",function(x) x.b = x.a 
            x.a = 0 
            x.c=x.c+(255)  end}
m["10122190902915292990"]={"Lt",function(x) x.b = x.a + 255 
            x.a = 0 
            x.c=x.c+(255)  end}
m["101221919091902990291529"]={"Lt",function(x) x.b = x.a 
            x.a = 1  end}
m["1012219091902990291529"]={"Lt",function(x) x.b = x.a + 255 
            x.a = 1  end}
m["1012219190902990291529"]={"Lt",function(x) x.b = x.a 
            x.a = 1 
            x.c=x.c+(255)  end}
m["10122190902990291529"]={"Lt",function(x) x.b = x.a + 255 
            x.a = 1 
            x.c=x.c+(255)  end}
m["101223919091902915292990"]={"Le",function(x) x.b = x.a 
            x.a = 0  end}
m["1012239091902915292990"]={"Le",function(x) x.b = x.a + 255 
            x.a = 0  end}
m["1012239190902915292990"]={"Le",function(x) x.b = x.a 
            x.a = 0 
            x.c=x.c+(255)  end}
m["10122390902915292990"]={"Le",function(x) x.b = x.a + 255 
            x.a = 0 
            x.c=x.c+(255)  end}
m["101223919091902990291529"]={"Le",function(x) x.b = x.a 
            x.a = 1  end}
m["1012239190902990291529"]={"Le",function(x) x.b = x.a 
            x.a = 1 
            x.c=x.c+(255)  end}
m["1012239091902990291529"]={"Le",function(x) x.b = x.a + 255 
            x.a = 1  end}
m["10122390902990291529"]={"Le",function(x) x.b = x.a + 255 
            x.a = 1 
            x.c=x.c+(255)  end}
m["101291902915292990"]={"Test",function(x) x.b = 0 
            x.c = 0  end}
m["10123491902915292990"]={"Test",function(x) x.b = 0 
            x.c = 1  end}
m["9190101229152991902990"]={"TestSet",function(x) x.b = x.c 
            x.c = 0  end}
m["919010123429152991902990"]={"TestSet",function(x) x.b = x.c 
            x.c = 1  end}
m["149190"]={"Call",nil}
m["909114919115"]={"Call",nil}
m["9091149114511590"]={"Call",function(x) x.b=x.b-(x.a - 1) end}
m["9014919115"]={"Call",nil}
m["90149114511590"]={"Call",function(x) x.b=x.b-(x.a - 1) end}
m["9091149114511530"]={"Call",nil}
m["903314919115139015919"]={"Call",function(x) x.c=x.c-(x.a - 2) end}
m["90911491"]={"Call",nil}
m["90141491301615133015919"]={"Call",nil}
m["901414919115301615133015919"]={"Call",function(x) x.b=x.b-(x.a - 1) end}
m["9014149114511590301615133015919"]={"Call",function(x) x.b=x.b-(x.a - 1) end}
m["90149114511530"]={"Call",nil}
m["9033149114511590139015919"]={"Call",function(x) x.b=x.b-(x.a - 1) 
            x.c=x.c-(x.a - 2)  end}
m["9033149114511530139015919"]={"Call",function(x) x.c=x.c-(x.a - 2) end}
m["90331491901315919"]={"Call",function(x) x.c=x.c-(x.a - 2) end}
m["9014149114511530301615133015919"]={"Call",nil}
m["9027149114511590"]={"TailCall",function(x) x.b=x.b-(x.a - 1) end}
m["9027149114511530"]={"TailCall",nil}
m["27149190"]={"TailCall",nil}
m["27"]={"Return",nil}
m["279190"]={"Return",nil}
m["9027145130"]={"Return",nil}
m["902714511590"]={"Return",function(x) x.b=x.b+(2) end}
m["9027919115"]={"Return",nil}
m["909115159191101122102391152990911524911529909115"]={"ForLoop",function(x) x.b=x.b-(x.pc + 1) end}
m["909191151011122210122291152990911521911529909115"]={"ForPrep",function(x) x.b=x.b-(x.pc + 2) end}
m["909015331491911591139115991012912990291529"]={"TForLoop",function(x) x.b = 0 end}
m["909113153014691"]={"SetList",nil}
m["909113159014691"]={"SetList",function(x) x.b=x.b-(x.a) end}
m["3313289132899910352512490999"]={"Close",nil}
m["990331473333927999999913902915299291012259916331991633299152891901483"]={"Closure",nil}
m["91901489903"]={"Closure",nil}
m["903016151330941691"]={"VarArg",nil}
m["909013919416"]={"VarArg",function(x) x.b=x.b-(x.a - 1) end}
return m

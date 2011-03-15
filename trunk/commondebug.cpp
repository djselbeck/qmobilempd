#include "commondebug.h"

CommonDebug::CommonDebug(QString out)
{
#ifdef DEBUG
    qDebug(out.toAscii());
#endif
}


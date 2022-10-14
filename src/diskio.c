/*-----------------------------------------------------------------------*/
/* Low level disk I/O module skeleton for Petit FatFs (C)ChaN, 2014      */
/*-----------------------------------------------------------------------*/

#include <string.h>
#include "diskio.h"
#include "sdc.h"
#include <stdlib.h>

static BYTE buffer[512];
static __zpage int bufptr;
static DWORD current_sector = -1;

/*-----------------------------------------------------------------------*/
/* Initialize Disk Drive                                                 */
/*-----------------------------------------------------------------------*/

DSTATUS disk_initialize (void) {
  switch (sdc_init()) {

      case DEV_NOMEDIA:
        return RES_NOTRDY;

      case 0:
        return RES_OK;

      case DEV_CANNOT_INIT:
      default:
        return RES_ERROR;
    }
}



/*-----------------------------------------------------------------------*/
/* Read Partial Sector                                                   */
/*-----------------------------------------------------------------------*/

DRESULT disk_readp (BYTE* buff,     /* Pointer to the destination object */
                    DWORD sector,   /* Sector number (LBA) */
                    UINT offset,    /* Offset in the sector */
                    UINT count      /* Byte count (bit15:destination) */
                   )
{
  // Ensure sector in buffer
  if (sector != current_sector) {
    // Read the sector
    short read = sdc_read(sector, buffer, 512);
    if (read != 512) {
      // This failed
      current_sector = -1;
      return RES_ERROR;
    }
    current_sector = sector;
  }

  memcpy(buff, buffer + offset, count);

  return RES_OK;
}



/*-----------------------------------------------------------------------*/
/* Write Partial Sector                                                  */
/*-----------------------------------------------------------------------*/

DRESULT disk_writep (const BYTE* buff, /* Pointer to the data to be written,
                                          NULL:Initiate/Finalize write operation */
                     DWORD sc          /* Sector number (LBA) or Number of bytes to send */
                    )
{
  DRESULT res = RES_OK;

  if (!buff) {
    if (sc) {
      // Initiate write process
      bufptr = 0;
      current_sector = -1;  // invalidate buffer for read
    } else {
      // Finalize write process
      if (bufptr < 512) {
        memset(buffer + bufptr, 0, 512 - bufptr);
      }
      sdc_write(sc, buffer, 512);
    }
  } else {
    // Send data to the disk
    memcpy(buffer + bufptr, buff, sc);
    bufptr += sc;
  }

  return res;
}

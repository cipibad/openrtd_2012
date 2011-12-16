#ifndef __LINUX_USB_SETTING_H
#define __LINUX_USB_SETTING_H

#define USB_TO_NOTIFY_TIER
#define USB_HACK_DISABLE_PORT_POWER
//#define USB_TEST_TRANSFER_TIME
//#define USB_OHCI_DEBUG_SET_WATCH_POINT
//#define USB_HACK_TRANSPORT_ERROR
#define USB_HACK_EHCI_WIFI_UNPLUG_HANG
//#define USB_TEST_SCSI_READ_FORMAT_CAPACITITES
//#define USB_STORAGE_SPEEDUP_PORT_ONE
#define USB_HACK_ON_USB_TO_IDE_ERROR
//#define USB_DEVICE_RETRY_ONCE
//#define USB_TEST_MODE_DISABLE_IRQ_2
#define USB_ROOT_PORT_SUSPEND_RESUEM_BY_REGS
#define USB_WARNING_WHEN_DEVICE_NOT_SUPPORT
#define USB_FREE_IRQ_AT_SUSPEND_MODE
#define USB_USE_ALIGNMENT
//#define USB_EHCI_DEBUG_QH_QTD

// for mars
//#define USB_MARS_PHY_SETTING_FOR_FPGA
#define USB_MARS_IRQ_CHECK_DATA_READY
#define USB_MARS_EHCI_CONNECTION_STATE_POLLING
#define USB_MARS_HOST_TEST_MODE_JK
//#define USB_MARS_HOST_LS_HACK
//#define USB_MARS_OTG_ENABLE_IN_PORT_TWO
#define USB_MARS_OTG_VERIFY_TEST_CODE

/************************************************
 * other setting
 ************************************************/

#ifdef USB_USE_ALIGNMENT
	#define USB_EHCI_CHECK_ALIGNMENT
	#define USB_OHCI_CHECK_ALIGNMENT
	#define USB_512B_ALIGNMENT

	#ifdef USB_EHCI_CHECK_ALIGNMENT
		#define USB_EHCI_CHECK_ALIGNMENT_SIZE	(0x200) // 512B
	#endif /* USB_EHCI_CHECK_ALIGNMENT */

	#ifdef USB_OHCI_CHECK_ALIGNMENT
		#define USB_OHCI_CHECK_ALIGNMENT_SIZE	(0x400) // 1k
	#endif /* USB_OHCI_CHECK_ALIGNMENT */

	#ifdef USB_512B_ALIGNMENT
		#define USB_512B_ALIGNMENT_SIZE		(512)
	#endif /* USB_512B_ALIGNMENT */

#endif

#ifdef USB_STORAGE_SPEEDUP_PORT_ONE
	#define USB_STORAGE_SPEEDUP_DEVPATH	"1.1"
	#define USB_STORAGE_SPEEDUP_TIME	(2)
#endif /* USB_STORAGE_SPEEDUP_PORT_ONE */

#ifdef USB_HACK_ON_USB_TO_IDE_ERROR
// hack for usb to ide, cfyeh add 2007/03/23 +
	#define USB_HACK_DISABLE_ALL_SCSI_DEVICE
	#define USB_HACK_SET_US_FLIDX_DISCONNECTING
	//#undef USB_HACK_SET_US_FLIDX_DISCONNECTING

	#define USB_STORAGE_DATA_ERROR_RETRY_TIMES	(3)
	#define USB_STORAGE_BULK_RESET_RETRY_TIMES	(1)
// hack for usb to ide, cfyeh add 2007/03/23 -
#endif

#ifdef USB_DEVICE_RETRY_ONCE
	#define USB_DEVICE_RETRY_DELAY_TIME	(5)
#endif /* USB_DEVICE_RETRY_ONCE */

#if ! defined (USB_MARS_PHY_SETTING_FOR_FPGA)
	#define USB_PHY_SETTING_NORMAL
#endif

//for mars
#ifdef USB_MARS_OTG_ENABLE_IN_PORT_TWO
	#define USB_MARS_OTG_TEST_MODE_JK
	#define USB_MARS_OTG_OVERCURRENT_DETECT
#endif

#endif /* __LINUX_USB_SETTING_H */

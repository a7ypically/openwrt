#
# Copyright (C) 2011 OpenWrt.org
#

. /lib/functions/system.sh

PART_NAME=firmware
REQUIRE_IMAGE_METADATA=1

gl_ar300m_do_upgrade () {
	local size="$(mtd_get_part_size 'ubi')"
	case "$size" in
	132120576)
		nand_do_upgrade "$ARGV"
		;;
	*)
		default_do_upgrade "$ARGV"
		;;
	esac
}

routerstation_do_upgrade() {
	local append
	local kern_length=0x$(dd if="$1" bs=2 skip=1 count=4 2>/dev/null)

	[ -f "$CONF_TAR" -a "$SAVE_CONFIG" -eq 1 ] && append="-j $CONF_TAR"
	dd if="$1" bs=64k skip=1 2>/dev/null | \
		mtd -r $append -Fkernel:$kern_length:0x80060000,rootfs write - kernel:rootfs
}

platform_check_image() {
	return 0
}

platform_do_upgrade() {
	local board=$(board_name)

	case "$board" in
	glinet,ar300m)
		gl_ar300m_do_upgrade "$ARGV"
		;;
	ubnt,routerstation|\
	ubnt,routerstation-pro)
		routerstation_do_upgrade "$ARGV"
		;;
	*)
		default_do_upgrade "$ARGV"
		;;
	esac
}

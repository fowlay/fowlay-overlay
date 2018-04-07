# Copyright 1999-2017 Gentoo Foundation         -*-Shell-script-*-
# Distributed under the terms of the GNU General Public License v2


EAPI=6

DESCRIPTION="Support for MS Sidewinder X4, X6 and Logitech G105, G710, G710+"
HOMEPAGE="https://github.com/tolga9009/sidewinderd"
declare -r COMMIT=d6d2513dad4a044aaecb297e41bf5e5f04e7bbf1
SRC_URI="https://github.com/tolga9009/sidewinderd/archive/${COMMIT}.zip -> ${P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-util/cmake dev-libs/libconfig dev-libs/tinyxml2"
RDEPEND="${DEPEND}"

function src_unpack {
    unpack ${A}
    mv `dirname ${S}`/${PN}-${COMMIT} ${S}
}

function src_compile {
    mkdir -p build
    (cd build
     cmake -DCMAKE_INSTALL_PREFIX=/usr ..
     emake
    )
}

function src_install {
    (cd build
     emake DESTDIR="${D}" install
    )

    if ! declare -p DOCS &>/dev/null ; then
        local d
        for d in README* ChangeLog AUTHORS NEWS TODO CHANGES \
                         THANKS BUGS FAQ CREDITS CHANGELOG ; do
            if [[ -s "${d}" ]]; then
		dodoc "${d}"
	    fi
        done
    elif [[ $(declare -p DOCS) == "declare -a "* ]] ; then
        dodoc "${DOCS[@]}"
    else
        dodoc ${DOCS}
    fi

    local -r ETC=/etc

    newinitd "${FILESDIR}"/sidewinderd.1 sidewinderd

    insinto ${ETC}
    newins "${FILESDIR}"/sidewinderd.conf.1 sidewinderd.conf

    sed -i -e '/ExecStart=/s:$:'" -c ${ETC}/sidewinderd.conf -d:" \
	${ED}/usr/lib/systemd/system/sidewinderd.service
    
    elog "Please edit ${ETC}/sidewinderd.conf,"
    elog "then add sidewinderd to the default runlevel"
}

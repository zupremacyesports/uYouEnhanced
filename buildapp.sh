read -p $'\e[34m==> \e[1;39mPath to the decrypted YouTube.ipa or YouTube.app: ' PATHTOYT
PATHTOYT="$(echo $PATHTOYT | tr -d "'")"
if [[ "$PATHTOYT" != /* ]]; then
  PATHTOYT="./$PATHTOYT"
fi
if [[ ! -f "$PATHTOYT" ]]; then
  echo "$PATHTOYT doesn't exist"
  exit 1
fi
act --container-options "-v $PATHTOYT:$(pwd)/YouTube.ipa"
if [[ $? -eq 0 ]]; then
  mkdir -p packages
  cp artifacts/*/*/* packages
  gzip -S .gz__ -d packages/*.gz__
  open packages
  echo "\033[0;32m==> \033[1;39mSHASUM256: $(shasum -a 256 packages/*.ipa)"
else
  echo "\033[0;31m==> \033[1;39mFailed building uYouPlus"
fi

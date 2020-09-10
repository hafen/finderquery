import React from 'react';
// import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';
// import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';

export default function DownloadDialog({ open, path }) {

  return (
    <Dialog
      disableBackdropClick
      disableEscapeKeyDown
      open={open}
      aria-labelledby="alert-dialog-title"
      aria-describedby="alert-dialog-description"
    >
      <DialogTitle id="alert-dialog-title">{"Doanloading documents"}</DialogTitle>
      <DialogContent>
        <DialogContentText id="alert-dialog-description">
          {`Documents are being downloaded to the following location: ${path}. This could take some time. This dialog will remain open until the download has completed.`}
        </DialogContentText>
      </DialogContent>
      {/* <DialogActions>
        <Button onClick={handleClose} color="primary">
          Disagree
        </Button>
        <Button onClick={handleClose} color="primary" autoFocus>
          Agree
        </Button>
      </DialogActions> */}
    </Dialog>
  );
}
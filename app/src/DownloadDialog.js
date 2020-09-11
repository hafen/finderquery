import React from 'react';
// import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';
// import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';
import LinearProgress from '@material-ui/core/LinearProgress';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
  path: {
    background: '#eee',
    fontFamily: 'monospace',
    fontWeight: 600,
    fontSize: 14
  },
  progress: {
    marginBottom: 22
  }
}));

export default function DownloadDialog({ open, path }) {
  const classes = useStyles();

  return (
    <Dialog
      disableBackdropClick
      disableEscapeKeyDown
      open={open}
      aria-labelledby="alert-dialog-title"
      aria-describedby="alert-dialog-description"
    >
      <DialogTitle id="alert-dialog-title">{"Downloading documents"}</DialogTitle>
      <DialogContent>
        <LinearProgress className={classes.progress} color="secondary" />
        <DialogContentText id="alert-dialog-description">
          {`Documents are being downloaded to `}
          <span className={classes.path}>{`/tmp/${path}`}</span>
          {` on the server. This could take some time. This dialog will remain open until the download has completed.`}
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
import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import IconButton from '@material-ui/core/IconButton';
import CloseIcon from '@material-ui/icons/Close';
import { SnackbarProvider } from 'notistack';
import * as serviceWorker from './serviceWorker';


// expand: {
//   padding: '8px 8px',
//   transform: 'rotate(0deg)',
//   transition: theme.transitions.create('transform', {
//       duration: theme.transitions.duration.shortest,
//   }),
// },

const notistackRef = React.createRef();
const onClickDismiss = key => () => { 
  notistackRef.current.closeSnackbar(key);
}

ReactDOM.render(
  <React.StrictMode>
    <SnackbarProvider
      maxSnack={3}
      ref={notistackRef}
      action={(key) => (
        <IconButton onClick={onClickDismiss(key)}>
          <CloseIcon />
        </IconButton>
      )}
      anchorOrigin={{
        vertical: 'bottom',
        horizontal: 'right'
      }}
    >
      <App />
    </SnackbarProvider>
  </React.StrictMode>,
  document.getElementById('root')
);

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();

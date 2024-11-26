import http from 'http';

const url = process.env.ALB_EKS ?? "localhost:8080"

export const lambdaHandler = async (event) => {
  const cpf = event.queryStringParameters?.cpf || null;
  if (!cpf || cpf == "false") return generatePolicy('user', 'Allow', '*');;

  try {
    const isAuthorized = await callExternalEndpoint(cpf);
    return generatePolicy('user', isAuthorized ? 'Allow' : 'Deny', '*');
  } catch (error) {
    return generatePolicy('user', 'Deny', '*');
  }
};

const callExternalEndpoint = (cpf) => {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: url,
      path: `/api/v1/clientes/${cpf}`,
      method: 'GET',
    };

    const req = http.request(options, (res) => {
      resolve(res.statusCode === 200);
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.end();
  });
};

const generatePolicy = (principalId, effect, resource) => {
  return {
    principalId,
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: effect,
          Resource: resource,
        },
      ],
    },
  };
};
